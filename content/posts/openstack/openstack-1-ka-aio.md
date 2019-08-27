title: Install Single-Node Openstack with Kolla-Ansible
slug: openstack-1-ka-aio
category: guides
date: 2019-08-11
modified: 2019-08-11
status: published



# Objective
Install a single-node non-HA openstack cluster for testing purposes using
Kolla-Ansible. This will be a nested hypervisor, so performance is not a
concern.

The version of Openstack to be installed is [Rocky](https://www.openstack.org/software/rocky/).

# Environment
- Installed on a new VM hosted by Breqwatr's on-prem Openstack
- VM running Ubuntu 18.04
- 2 SSD virtual drives, 200GB for the OS and 300GB for Cinder LVM
- Two VLAN interface ports, one for API endpoints and one for neutron
- Using the public Rocky images from Kolla on Docker Hub



# Update your system

```bash
apt-get update && apt-get upgrade -y
```


# Create Volume Group for Cinder

Openstack Cinder supports a huge [list of backend storage providers](https://docs.openstack.org/cinder/rocky/reference/support-matrix.html),
but the simplest to set up is just using an LVM volume group on the host.
Cinder will use it to carve out logical volumes for each cloud block storage
device. This isn't highly available, but that's ok for a dev cloud.

Create a volume group using a dedicated disk.
In this example, I'll use /dev/vdb for VMs.

The name of this volume group is defined in the globals.yml file as
`cinder_volume_group`, and can be changed as needed.

```bash
pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb
```


# Install Ansible

Kolla-Ansible requires that Ansible be pre-installed. Apt can install it too,
but pip tends to install a newer version. Some old versions aren't compatible
with Kolla-Ansible.
```
apt-get -y install python python-pip
pip install ansible
```


# Install Kolla-Ansible

## Check out the K8S code
Git comes pre-installed on Ubuntu 18.04. Use it to pull a stable branch of
Kolla-Ansible. Check out the code and use pip to install Kolla-Ansible.

Make sure to use the stable branch associated with Rocky. Kolla-Ansible doesn't
work right when installing versions of Openstack that don't match git stable
branch used.

```bash
cd ~
git clone https://github.com/openstack/kolla-ansible.git
cd ~/kolla-ansible
git checkout stable/rocky
pip install .
```


# Generate Openstack Config Files

## Openstack service config files
Kolla-Ansible will accept partial config files and inject their content over
the sane defaults it picks for the openstack services. Only define the changes
to the default configs you want. I've included the ones I think are most
important.

Create the directory to store the Openstack config changes.
```bash
mkdir -p /etc/kolla/config
```

### Nova (Compute)
Create the directory for nova config files.

```bash
mkdir /etc/kolla/config/nova
```

Disable overcommit, reserve some resources for the base OS

`vi /etc/kolla/config/nova/nova-compute.conf`
```ini
[DEFAULT]
allocation_ratio = 1
ram_allocation_ratio = 1
reserved_host_memory_mb = 1024
reserved_host_cpus = 1
```


### Neutron (Networking)
Create the directory for the neutron config files.
```bash
mkdir -p /etc/kolla/config/neutron
```

Enable VLANs, port security, and DNS features

`vi /etc/kolla/config/neutron/ml2_conf.ini`
```ini
[ml2]
extension_drivers = port_security,dns

[ml2_type_vlan]
network_vlan_ranges = physnet1:1:4094
```


## Globals file

The globals file contains most of the important deployment settings for KA.

Check these two links for more info:
- [openstack.org KA advanced reference](https://docs.openstack.org/kolla-ansible/latest/admin/advanced-configuration.html)
- [Github page for globals file](https://github.com/openstack/kolla-ansible/blob/master/etc/kolla/globals.yml)

Any config not defined is set by the ansible defaults files.

The globals file can specify your openstack version, where it will pull its
containers from, and which containers will be deployed. Be sure to replace
`kolla_internal_vip_address`'s value with your VIP address.

The VIP can't be used by your existing network card, else HAproxy will throw a
fit and Kolla-Ansible will fail at the mariadb step.

The networking in this example is as simple as it gets. You can really split
things up in this file if you want to. Note the network interface name too, it
may be different from yours.

`vi /etc/kolla/globals.yml`

```yaml

---
# Container details, matches docker hub tags
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "rocky"

# APIs listen on this VIP
kolla_internal_vip_address: "10.100.202.254"

# Interface used for VXLANS and APIs. See docs to split this out into many nics
network_interface: "ens3"

# Used for the VLANS, give it the whole device
neutron_external_interface: "ens6"

# If you have more than one install in the broadcast domain, make this unique
keepalived_virtual_router_id: "77"

# No https
kolla_enable_tls_external: "no"

# Which services/containers to deploy?
enable_glance: "yes"
enable_haproxy: "yes"
enable_keepalived: "yes"
enable_keystone: "yes"
enable_mariadb: "yes"
enable_memcached: "yes"
enable_neutron: "yes"
enable_nova: "yes"
enable_rabbitmq: "yes"
enable_chrony: "yes"
enable_cinder: "yes"
enable_cinder_backup: "no"
enable_cinder_backend_lvm: "yes"
enable_fluentd: "yes"
enable_nova_ssh: "yes"
keystone_admin_user: "admin"
keystone_admin_project: "admin"
glance_backend_file: "yes"
cinder_backend_ceph: "no"
cinder_volume_group: "cinder-volumes"
enable_ceph: "no"

# Use "qemu" for nested virtualization, use KVM for metal w/ Cpu support
nova_compute_virt_type: "qemu"

# Web UI
enable_horizon: "yes"
```


## Passwords file
The passwords file is empty initially, its just a template to be filled in with
random password from KA. The `kolla-genpwd` command populates it.

```bash
cp ~/kolla-ansible/etc/kolla/passwords.yml /etc/kolla
kolla-genpwd
```

## Ansible Inventory
The KA ansible inventory defines which roles will be assigned to which hosts.
The all-in-one inventory file assigns all roles to localhost.

```bash
cp ~/kolla-ansible/ansible/inventory/all-in-one /etc/kolla/inventory
```

## Disable ISCSI
Consider disabling the iscsi stuff if you don't need it. Its pretty broken in
the pike branch. Just comment out the `:children` groups in both categories.

`vi /etc/kolla/inventory`
```ini
# ...

[iscsid:children]
#compute
#storage
#ironic-conductor

[tgtd:children]
#storage

# ...

```

# Install Openstack using Kolla-Ansible

First run the bootstrap command to install docker and tune the server. In older
branches it will add the wrong key for the apt repo, so do that yourself.

```bash
kolla-ansible -i /etc/kolla/inventory bootstrap-servers
kolla-ansible -i /etc/kolla/inventory deploy
kolla-ansible -i /etc/kolla/inventory post-deploy
```

# Install the Openstack Command Line
```bash
pip install python-openstackclient
```



# References
- [openstack.org's kolla-ansible developer quickstart](https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html)
