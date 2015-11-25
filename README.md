#Personal Ansible Playbooks

##Description
This is an attempt to use ansible to unify my personal workstation settings into a single repository. It has also grown a bit to add support for some time saving configurations used at work and training.

##Usage
To bootstrap a workstation machine

```
if [ "$(lsb_release -i)" = "Ubuntu" ] && [ "$(lsb_release -r | cut -f 2)" \> "15.04" ]; then
  git clone https://github.com/teddyphreak/ansible-playbooks.git ansible-playbooks
  ansible-playbook localhost.yml --ask-become-pass
fi
```

For other roles, you can clone the repo and define custom playbooks and inventory sources

## Support
* Roles are only supported under Ubuntu Wily, Debian Jesse, RHEL 7, CentOS 7 or later versions.

## Testing
Please use the vagrant provided images to ensure roles work as intended on supported distribution versions

```
ansible-playbook testing.yml 
```

You can define additional machines in the vagrant file and use other ansible provisioning settings, the inventory script will include them automatically in the inventory output
