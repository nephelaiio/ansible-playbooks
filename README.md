#Personal Ansible Playbooks
[![Build Status](https://travis-ci.org/nephelaiio/ansible-playbooks.svg?branch=master)](https://travis-ci.org/nephelaiio/ansible-playbooks)

##Description
Ansible playbooks for fun and profit

## Requirements
[Ansible](https://www.ansible.com/) must be available on your path. You can also install it using pip globally or to a [virtualenv](https://virtualenv.pypa.io/en/stable/) (recommended). 

```
pip install -r requirements.txt
```

## Testing
[Docker](https://docker.io) must be available to your account on your system. Issue the following commands to trigger a test run:

```
pip install -r requirements.txt
pytest -s
```

You can check the [Travis configuration file](/.travis.yml) for an example/more details.

##Usage
To apply playbook workstation.yml, do

```
ansible-playbook playbooks/workstation.yml -u $(whoami)
```

Remember to add the --ask-become-pass swtich to all 'ansible-playbook' commands if you do not have passwordless sudo configured in the target host.

## OS Support
Playbooks are tested under Ubuntu, support for Arch, Debian Jessie and Centos 7 (and higher) is available in most playbooks
