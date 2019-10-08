nephelaiio.traefik
======================

[![Build Status](https://travis-ci.org/nephelaiio/ansible-traefik.svg?branch=master)](https://travis-ci.org/nephelaiio/ansible-role-traefik)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.traefik-blue.svg)](https://galaxy.ansible.com/nephelaiio/traefik/)

An opinionated [ansible role](https://galaxy.ansible.com/nephelaiio/traefik) for installing traefik along with consul as configuration and catalog backend and optional integration with keepalived and powerdns recursors and servers

A brief description of the role goes here.

Role Variables
--------------

The most common user overridable parameters for the role are

| required | variable                      | description                                 | default                                        |
| ---      | ---                           | ---                                         | ---                                            |
| *yes*    | traefik_service_domain        | base domain for traefik frontends           | _undefined_                                    |
| *yes*    | traefik_consul_domain         | base domain for consul dns                  | _undefined_                                    |
| *yes*    | traefik_consul_raw_key        | consul encryption key                       | _undefined_                                    |
| no       | traefik_group_name            | inventory group name for traefik hosts      | traefik                                        |
| no       | traefik_cluster_ip            | keepalived cluster ip                       | _undefined_                                    |
| no       | traefik_consul_tls_dir        | consul base tls path                        | /etc/ipa                                       |
| no       | traefik_consul_tls_ca_crt     | consul tls ca file                          | /etc/ipa/ca.crt                                |
| no       | traefik_consul_tls_server_crt | consul tls cert file                        | /etc/ipa/{{ ansible_fqdn }}.crt                |
| no       | traefik_consul_tls_server_key | consul tls cert key                         | /etc/ipa/{{ ansible_fqdn }}.key                |
| no       | traefik_acme_directory        | acme directory for tls certificate creation | https://acme-v02.api.letsencrypt.org/directory |

You can view an example redefinition of some of the above parameters, most notably the ones concerning certificate ca in the [CI test configuration file](/molecule/default/molecule.yml)

Please refer to the [defaults file](/defaults/main.yml) for an up to date list of input parameters.

Dependencies
------------

* [nephelaiio.plugins](https://github.com/nephelaiio/plugins) for required filter plugins
* [nephelaiio.pip](https://github.com/nephelaiio/pip) for pip package installation
* [brianshumate.consul](https://github.com/brianshumate/ansible-consul) for consul configuration
* [kibatic.traefik](https://github.com/kibatic/ansible-traefik) for traefik configuration
* [mrlesmithjr.keepalived](https://github.com/mrlesmithjr/ansible-keepalived) for keepalived configuration

See [https://raw.githubusercontent.com/nephelaiio/ansible-role-requirements/master/requirements.txt](requirements) and [meta.yml](meta) files for more details

Example Playbook
----------------

```
- hosts: servers
  roles:
    - nephelaiio.traefik
  
```

License
-------

This project is licensed under the terms of the [MIT License](/LICENSE)
