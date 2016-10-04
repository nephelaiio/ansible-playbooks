import pytest
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
playbook_dir = '.'
playbook_ignore = ['setup-playbook.yml']
playbook_lint_command = 'ansible-lint'
playbook_lint_success = 0
playbook_test_command = 'molecule test'
playbook_test_success = 0


def list_playbooks(playbook_dir):
    """
    retrieve the list of playbooks in a directory
    :param playbook_dir: the path to search for playbooks
    """
    playbook_files = [f  for f in os.listdir(playbook_dir)
            if os.path.isfile(os.path.join(cwd, playbook_dir, f)) and
            re.match(".*-playbook.yml$", f) and
            not f in playbook_ignore]
    playbook_files = [os.path.join(playbook_dir, f) for f in playbook_files]
    return(playbook_files)


def playbook_test_dir(playbook):
    """
    return the canonical location of a playbook's test directory
    :param playbook: the target playbook
    """
    return(os.path.join(test_exe_dir, os.path.basename(playbook)))


def bootstrap_test_tree(playbook):
    """
    bootstrap the directory structure for testing a single playbook
    :param playbook: the playbook file to bootstrap for testing
    """
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
    return(test_dir)


@pytest.mark.parametrize("playbook", list_playbooks(playbook_dir))
def test_run_playbook(playbook):
    """
    run tests for a particular playbook
    :arg playbook: the target playbook
    """
    print("Bootstrapping test for playbook {0}".format(playbook))
    test_dir = bootstrap_test_tree(playbook)
    last_dir = cwd
    print("Testing playbook {0}".format(playbook))
    try:
        os.chdir(test_dir)
        assert call(playbook_test_command.split()) == 0
    finally:
        os.chdir(last_dir)


@pytest.mark.parametrize("playbook", list_playbooks(playbook_dir))
def test_lint_playbook(playbook):
    """
    perform a lint check on input playbook
    :param playbooks: the paths of the playbook file to test
    """
    print("Linting playbook {0}".format(playbook))
    assert call([playbook_lint_command] + [playbook]) == playbook_lint_success
