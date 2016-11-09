from paver.tasks import cmdopts, task, needs
from getpass import getuser
import pytest
from subprocess import call


def run_playbook(playbook, args):
    command = 'ansible-playbook {0} {1}'.format(playbook, args)
    print(command)
    call(command.split())


def build_args(options, task, defaults={}):
    args = ''
    for (long_opt, short_opt) in [('user', '-u'), ('inventory-file', '-i')]:
        if long_opt in options[task]:
            args = '{0} {1} {2}'.format(args, short_opt,
                                        options[task][long_opt])
        elif long_opt in defaults:
            args = '{0} {1} {2}'.format(args, short_opt, defaults[long_opt])
    return(args)


@task
@cmdopts([
    ('user=', 'u', 'connect as this user'),
    ('inventory_file=', 'i', 'inventory host path or csv host list')
])
def setup(options):
    run_playbook('setup-playbook.yml', build_args(options, 'setup'))


@task
@needs(['setup'])
@cmdopts([
    ('user=', 'u', 'connect as this user'),
    ('inventory_file=', 'i', 'inventory host path or csv host list')
], share_with=['setup'])
def workstation(options):
    run_playbook('workstation-playbook.yml',
                 build_args(options,
                            'workstation', {'user': getuser()}))


@task
def test_workstation():
    args = 'test/test_playbooks.py::test_workstation_playbook -s'.split()
    pytest.main(args)


@task
@needs(['setup'])
@cmdopts([
    ('user=', 'u', 'connect as this user'),
    ('inventory_file=', 'i', 'inventory host path or csv host list')
], share_with=['setup'])
def openstack(options):
    run_playbook('openstack-playbook.yml',
                 build_args(options,
                            'openstack', {'user': getuser()}))


def test_openstack():
    args = 'test/test_playbooks.py::test_openstack_playbook -s'.split()
    pytest.main(args)


@task
def lint():
    args = 'test/test_playbooks.py::test_lint'.split()
    pytest.main(args)


@task
def test():
    test_openstack()
    test_workstation()
