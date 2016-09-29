#Personal Ansible Playbooks
[![Build Status](https://travis-ci.org/nephelaiio/ansible-playbooks.svg?branch=master)](https://travis-ci.org/nephelaiio/ansible-playbooks)

##Description
Ansible playbooks for work and play.

## Requirements
[Ansible](https://www.ansible.com/) must be available on your path. You can also install it using pip globally or to a [virtualenv](https://virtualenv.pypa.io/en/stable/) (recommended). A self contained example using [virtualenv]() and [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/) follows:

```
git clone https://github.com/nephelaiio/ansible-playbooks.git ansible-playbooks
cd ansible-playbooks
mkvirtualenv ansible
workon ansible
pip install -r requirements.txt
```

## Testing
[Docker](https://docker.io) must be available to your account on your system. Issue the following commands to trigger a test run:

```
pip install -r requirements.txt
pytest
```

You can check the [Travis configuration file](/.travis.yml) for an example/more details.

##Usage
To apply a playbook called workstation.yml, do

```
ansible-galaxy install -r requirements.yml
ansible-playbook setup.yml
ansible-playbook workstation.yml
```

Simply add the --ask-become-pass swtich to both 'ansible-playbook' commands if you do not have passwordless sudo configured in the target host.

## OS Support
Roles are only supported under Arch, Ubuntu Xenial, Debian Jesse, CentOS 7 and later versions
