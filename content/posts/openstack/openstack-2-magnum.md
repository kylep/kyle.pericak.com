title: Deploy Magnum for OpenStack with Kolla-Ansible
slug: openstack-2-magnum
category: guides
tags: OpenStack, Kubernetes
date: 2019-08-27
modified: 2019-08-27
status: published


Magnum is the COE-as-a-Service project in OpenStack. COE stands for Container
Orchestration Engine. Magnum can deploy Kubernetes on OpenStack.

This guide will start from an already-deployed OpenStack Rocky cloud to deploy
Magnum.


To install openstack, I've written two posts:

- [OpenStack dev cluster in a VM](/openstack-1-vm-ka-aio.html)
- [OpenStack dev cluster on one metalserver](/openstack-3-metal-ka-aio.html)


---


# Configure Magnum Cluster Template & Dependencies

## Create an SSH Keypair

Enter a SSH public key for `$pub_key`.

The openstack command to create a keypair needs to load a file for the
public key, so echo it to a file first.

This key will be used in the COE template and injected into each container
host VM.

```bash
pub_key=""
echo $pub_key > id_rsa.pub
openstack keypair create --public-key id_rsa.pub k8s

# Optionally,clean up
rm id_rsa.pub
```

## Deploy CoreOS Glance Image

Magnum needs a base image to install Kubernetes onto.
The two supported options are fedora-atomic and coreos.

```bash
wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
apt-get install -y qemu-utils
bzip2 -d  coreos_production_openstack_image.img.bz2
qemu-img convert -f qcow2 \
  -O raw coreos_production_openstack_image.img coreos.raw

openstack image create --property os_distro=coreos --container-format bare \
  --disk-format raw --public --file coreos.raw coreos
```

## Create a Cinder Volume Type

If no cinder volume type has been created, one must be made.
The name `local-lvm` is an example, any name can be used.
If a volume type already exists, use it.

```bash
openstack volume type create --public local-lvm
```

## Create a flavor for the k8s nodes

This defines the size of the container host VMs.

```bash
openstack flavor create medium --disk 50 --vcpus 1 --ram 4096
```

---


# Install Magnum
These steps assume that Kolla-Ansible is being used.

## Enable Magnum in globals.yml

Also specify the volume type.

```yaml
enable_magnum: "yes"
default_docker_volume_type: "local-lvm"
```

If the volume type is not defined, the following error will occur:
```text
Property error: resources.docker_volume.properties.volume_type: Error validating value '': The VolumeType () could not be found.
```

## Install the Magnum CLI
```bash
pip install python-magnumclient
```

## Deploy Changes
If magnum was already enabled in the globals file, reconfigure. Else, deploy.

```bash
# to reconfigure:
kolla-ansible -i /etc/kolla/inventory reconfigure

# to deploy:
kolla-ansible -i /etc/kolla/inventory deploy
```

## Show Container Orchestration Engine Service Status
```bash
openstack coe service list
```


---



## Create a Kubernetes ClusterTemplate
See [here](https://docs.openstack.org/magnum/latest/user/#overview) for the
various arguments available to the cluster template create command.

Create the Container Orchestration Engine template

```bash
openstack coe cluster template create \
  --coe kubernetes \
  --image coreos \
  --external-network vlan3-net \
  --keypair k8s \
  --flavor medium \
  --volume-driver cinder \
  --network-driver flannel \
  --dns-nameserver 8.8.8.8 \
  --master-flavor medium \
  --server-type vm \
  --docker-volume-size 5 \
  k8s

openstack coe cluster template list
```

---


# Create the Kubernetes Cluster

```bash
openstack coe cluster create --cluster-template k8s --node-count 1 kubernetes1

openstack coe cluster list
```

Watch the status in the `coe cluster list` output.

It will start as `CREATE_IN_PROGRESS` if things are working, then move to
either `CREATE_FAILED` or `CREATE_COMPLETE`.

If the create failed, its google time. Otherwise, the K8s cluster is now live!



---


# Reference Links
- [OpenStack Magnum User Guide](https://docs.openstack.org/magnum/latest/user/)
