import os
import re
import sys
import shutil
import yaml
from subprocess import call
from os.path import curdir as cwd

test_src_dir = 'test'
test_exe_dir = '.test'
molecule_playbook = 'playbook.yml'

"""
retrieves the list of playbooks in playbook_dir
:arg playbook_dir: the path to search for playbooks
"""
def list_playbooks(playbook_dir):
    playbook_files = [f  for f in os.listdir(playbook_dir) 
            if os.path.isfile(os.path.join(cwd, playbook_dir, f)) and
            re.match(".*.yml$", f)]
    playbook_files = [os.path.join(playbook_dir, f) for f in playbook_files]
    return(playbook_files)

def lint_playbooks(playbooks):
    return(call(["ansible-lint"] + playbooks))


def playbook_test_dir(playbook):
    return(os.path.join(test_exe_dir, os.path.basename(playbook)))

"""
bootstrap the directory structure for the test
:arg playbook: the playbook file to bootstrap
"""
def bootstrap_test_tree(playbook):
    test_dir = playbook_test_dir(playbook)
    shutil.rmtree(test_dir, True)
    shutil.copytree(test_src_dir, test_dir)
    playbook_stream = open(playbook, 'r')
    molecule_playbook_data = yaml.load(playbook_stream)
    def update_hosts(yaml_data):
       yaml_data['hosts'] = 'all'
       return yaml_data
    molecule_playbook_data = [update_hosts(x) for x in molecule_playbook_data]
    with open(os.path.join(test_dir, molecule_playbook), 'w') as test_playbook:
        test_playbook.write(yaml.dump(molecule_playbook_data, default_flow_style=False))
    
def test_playbook(playbook):
    last_dir = cwd
    test_dir = playbook_test_dir(playbook)
    try:
        os.chdir(test_dir)
        status = call(["molecule", "test"]) 
    finally:
        os.chdir(last_dir)
    return(status)


if __name__ == "__main__":
    exit_status = 0
    if (exit_status == 0):
        for p in list_playbooks('playbooks'):
            print("Linting playbook {0}".format(p))
            exit_status = lint_playbooks([p])
            if exit_status != 0:
                print("Error while linting playbook {0}. Aborting".format(p))
                break
    if (exit_status == 0):
        for p in list_playbooks('playbooks'):
            print("Bootstrapping test for playbook {0}".format(p))
            bootstrap_test_tree(p)
            print("Testing playbook {0}".format(p))
            if exit_status != 0:
                print("Error while testing playbook {0}. Aborting".format(p))
                break
            exit_status = test_playbook(p)
            if exit_status != 0:
                print("Error while testing playbook {0}. Aborting".format(p))
                break
    sys.exit(exit_status)

