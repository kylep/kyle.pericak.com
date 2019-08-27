title: Deploy Magnum for Openstack with Kolla-Ansible
slug: openstack-2-magnum
category: guides
date: 2019-08-27
modified: 2019-08-27
status: draft


Magnum is the COE-as-a-Service project in Openstack. COE stands for Container
Orchestration Engine. Magnum can deploy Kubernetes on Openstack.

This guide will start from an already-deployed Openstack Rocky cloud to deploy
Magnum.

Check out my [openstack all-in-one dev cloud deployment guide](openstack-1-ka-aio.md),
it sets up this guide's starting point.

# Configure Magnum
Beleive it or not, no configuration files need to be written.

# Install Magnum
Edit /etc/kolla/globals.yml and enable magnum:

`vi /etc/kolla/globals.yml`

```yaml
enable_magnum: "yes"
```

Remove Horizon
```bash
docker rm -f horizon
rm -r /etc/kolla/horizon
```

Deploy the Magnum container
```bash
kolla-ansible -i /etc/kolla/inventory deploy
```

# Install the Magnum CLI
```bash
pip install python-magnumclient
```

# Confirm COE service is up
```bash
openstack coe service list
```

# Prepare Openstack for Magnum's Cluster Template

## Create an SSH Keypair

Enter a SSH public key for `$pub_key`.

The openstack command to create a keypair needs to load a file for the
public key, so echo it to a file first.

This key will be used for the COE template and injected into each container
host VM.

```bash
pub_key=""
keypair_name="k8s"
echo $pub_key > id_rsa.pub
openstack keypair create --public-key id_rsa.pub $keypair_name

# Optionally,clean up
rm id_rsa.pub
```


## Deploy CoreOS Glance Image

Magnum needs a base image to install Kubernetes onto. The two supported options
are fedora-atomic and coreos.

### Download the CoreOS cloud image
```bash
wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
```

### Convert the cloud image to raw format
```bash
apt-get install -y qemu-utils

bzip2 -d  coreos_production_openstack_image.img.bz2


```


# Create a Kubernetes ClusterTemplate
See [here](https://docs.openstack.org/magnum/latest/user/#overview) for the
various arguments available to the cluster template create command.

```bash
openstack coe cluster template create \
  --coe kubernetes \
  --image coreos
  k8s

```
