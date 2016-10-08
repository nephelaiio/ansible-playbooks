from paver.easy import *
import pytest
import getpass
from subprocess import call


def run_playbook(playbook, args):
    command = 'ansible-playbook {0} {1}'.format(playbook, args)
    print(command)
    call(command.split()) 


def build_args(options, task, defaults={}):
    args = ''
    for (long_opt, short_opt) in [('user', '-u'), ('inventory-file', '-i')]:
        if long_opt in options[task]:
            args = '{0} {1} {2}'.format(args, short_opt, options[task][long_opt])
        elif long_opt in defaults:
            args = '{0} {1} {2}'.format(args, short_opt, defaults[long_opt])
    return(args)


@task
@cmdopts([
    ('user=', 'u', 'connect as this user'),
    ('inventory_file=', 'i', 'inventory host path or comma separated host list')
])
def setup(options):
    run_playbook('setup-playbook.yml', build_args(options, 'setup'))


@task
@needs(['setup'])
@cmdopts([
    ('user=', 'u', 'connect as this user'),
    ('inventory_file=', 'i', 'inventory host path or comma separated host list')
], share_with=['setup'])
def workstation(options):
    run_playbook('workstation-playbook.yml', build_args(options, 'workstation', {'user': getpass.getuser()}))


@task
def test():
    pytest.main(['-s'])
