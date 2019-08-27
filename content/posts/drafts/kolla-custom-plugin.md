title: Modifying Openstack Kolla Container Images
slug: kolla-custom-plugin.md
category: guides
date: 2019-08-26
modified: 2019-08-26
Status: draft


# Objective
Openstack Cinder needs some special software installed to work with certain
storage backends.

Kolla builds Docker containers for Openstack.

This guide covers how to configure Kolla to modify how builds a container, such
that it customizes the docker image by installing additional software inside
of it, without having to fork the Kolla git project.


# Install Kolla
This example uses the Rocky checkout to make Rocky based images. Use the stable
branch matching your openstack version else things get weird.

```bash
apt-get install -y git python python-pip
git clone https://github.com/openstack/kolla.git
get checkout stable/rocky
cd kolla
pip install .
```

## Configure Kolla
Use tox's genconfig envlist to generate a commented config file
```bash
tox -e genconfig
mkdir -p /etc/kolla
mv etc/kolla/kolla-build.conf /etc/kolla/
```

Then make any changes to the new config file as needed.


# Add the Modifications
Here's an example of adding the Pure Storage software to your cinder\_volume
image.

`vi /etc/kolla/template-overrides.j2`
```
{% extends parent_template %}

# Cinder Volume
{% block cinder_volume_ubuntu_setup %}
RUN pip install purestorage
{% endblock %}
```

# Build, Using Modifications
```bash
kolla-build --tag rocky-test-20190826-01 --template-override /etc/kolla/template-overrides.j2  cinder-volume
```
