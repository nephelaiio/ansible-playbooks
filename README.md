#consul Personal Ansible Playbooks
[![Build Status](https://travis-ci.org/nephelaiio/ansible-playbooks.svg?branch=master)](https://travis-ci.org/nephelaiio/ansible-playbooks)

## Description
Ansible playbooks for fun and profit

## Requirements
[Ansible](https://www.ansible.com/) must be available on your path. You can also install it using pip globally or to a [virtualenv](https://virtualenv.pypa.io/en/stable/) (recommended). 

```
pip install -r requirements.txt
```

## Testing

```
yamllint ./ -c ./.yamllint
flake8 ./
```

You can check the [Travis configuration file](/.travis.yml) for an example/more details.

## Usage
To apply playbook workstation.yml, do

```
ansible-playbook workstation.yml
```

Please browse the [root](/) directory for a list of available playbooks
