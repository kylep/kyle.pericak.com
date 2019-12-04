title: Operating OpenStack from Ansible
summary: Creating instances, volumes, and networks in OpenStack using Ansible
slug: openstack-ansible
category: openstack
tags: OpenStack, Ansible
date: 2019-12-03
modified: 2019-12-03
status: draft
image: openstack.png
thumbnail: openstack-thumb.png




**Assumption:** To avoid dealing with varying OpenStack policy configuration,
it's assumed that the scoped user has both `_member_` and `admin` on the scoped
project.

---

[TOC]

---


# Setup

Install Ansible and the OpenStack packages

```bash
apt-get install -y python ptyhon-pip
pip install \
  ansible \
  openstack-sdk

```

# Define Auth Settings

These settings could come from a `defaults/` yaml file, `set_facts`, the
Ansible inventory, or even be used in-line for each task. For the sake of this
example, the authentication settings will go in the `site.yml` file as follows:

`vi site.yml`

```yml
hosts: 127.0.0.1
  gather_facts: False
  become: True
  connection: local
  vars:
    openstack_auth:
      auth_url: https://<openstack vip/fqdn>:5000
      username: <username>
      password: <password>
      project_name: <project>
  roles:
    - openstack
```

# Servers

## List Servers Information

In the `openstack` role, use the `os_server_info` task to collect the server
data. If you're using a self-signed certificate, remember to use `verify`.


```yaml
- name: "Get server details"
  os_server_info:
    auth: "{{openstack_auth}}"
    verify: no
  register: servers_facts

- name: "Debug OpenStack server facts"
  debug:
    var: servers_facts
```

# Troubleshooting

## Error: shade is required for this module.

The version of Ansible you're using is too old.

## Error: openstacksdk is required for this module

You didn't install `openstacksdk` in the setup step.

## Server facts returns "auth": "VARIABLE IS NOT DEFINED!"


