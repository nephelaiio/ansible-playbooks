#Personal Ansible Playbooks

##Description
This is an attempt to use ansible to unify my personal workstation settings into a single repository. It has also grown a bit to add support for some time saving configurations used at work and training.

## Requirements
[Ansible](https://www.ansible.com/) must be available on your path. You can also install it using pip globally or to a [virtualenv](https://virtualenv.pypa.io/en/stable/) (recommended). A self contained example using [virtualenv]() and [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) follows:

```
git clone https://github.com/teddyphreak/ansible-playbooks.git ansible-playbooks
cd ansible-playbooks
mkvirtualenv ansible
workon ansible
pip install -r requirements.txt
```

##Usage
To bootstrap a workstation machine

```
ansible-galaxy install -r requirements.yml
ansible-playbook localhost.yml --ask-become-pass
```

For other roles, you can clone the repo and define custom playbooks and inventory sources

## OS Support
Roles are only supported under Arch, Ubuntu Wily, Debian Jesse, RHEL 7, CentOS 6, CentOS 7 and later versions

## To Do
* Add testing harness using [molecule](molecule.readthedocs.io)
