import pytest
import os
import re
import shutil
import yaml
from subprocess import call


test_src_dir = 'test'
test_exe_dir = '.test'
molecule_playbook = 'playbook.yml'
playbook_dir = 'playbooks'
playbook_ignore = ['setup.yml', 'nephelai.yml']
playbook_lint_command = 'ansible-lint'
playbook_lint_success = 0
playbook_test_command = 'molecule test'
playbook_test_success = 0


def list_playbooks(playbook_dir, ignore=playbook_ignore):
    """
    retrieve the list of playbooks in a directory
    :param playbook_dir: the path to search for playbooks
    """
    playbook_files = [f for f in os.listdir(playbook_dir)
                      if os.path.isfile(os.path.join(os.getcwd(),
                                                     playbook_dir,
                                                     f)) and
                      re.match(".*.yml$", f) and
                      f not in ignore]
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
        if 'hosts' in yaml_data:
            yaml_data['hosts'] = 'all'
        return yaml_data
    molecule_playbook_data = [update_hosts(x) for x in molecule_playbook_data]
    for aux_playbook in list_playbooks(playbook_dir, [playbook]):
        shutil.copy(aux_playbook, test_dir)
    with open(os.path.join(test_dir, molecule_playbook), 'w') as test_playbook:
        test_playbook.write(yaml.dump(molecule_playbook_data,
                                      default_flow_style=False))
    return(test_dir)


@pytest.mark.parametrize("playbook", list_playbooks(playbook_dir))
def test_run_playbook(playbook):
    """
    run tests for a particular playbook
    :arg playbook: the target playbook
    """
    print("\nCurrent dir is {0}".format(os.getcwd()))
    print("Bootstrapping test for playbook {0}".format(playbook))
    test_dir = bootstrap_test_tree(playbook)
    last_dir = os.getcwd()
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
    assert call([playbook_lint_command, playbook]) == playbook_lint_success


def test_workstation_playbook():
    """
    run tests for workstation.yml
    """
    playbook = 'workstation.yml'
    test_lint_playbook(playbook)
    test_run_playbook(playbook)


def test_openstack_playbook():
    """
    run tests for openstack.yml
    """
    playbook = 'openstack.yml'
    test_lint_playbook(playbook)
    test_run_playbook(playbook)


def test_unifi_playbook():
    """
    run tests for unifi.yml
    """
    playbook = 'unifi.yml'
    test_lint_playbook(playbook)
    test_run_playbook(playbook)


def test_lint():
    """
    run lint test for all playbooks
    """
    [test_lint_playbook(x) for x in list_playbooks(playbook_dir)]
