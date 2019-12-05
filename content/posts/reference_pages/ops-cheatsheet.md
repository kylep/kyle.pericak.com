title: Operations Reference Page
summary: Mini-posts and notes that are generally related to operations
slug: ops
category: reference pages
tags: Mac OS, Ubuntu, Vim, Docker, Ansible, Bash
date: 2019-09-11
modified: 2019-10-24
status: published
image: gear.png
thumbnail: gear-thumb.png


**This is a Reference Page:** Reference pages are collections of short bits
of information that are useful to look up but not long or interesting enough to
justify having their own dedicated post.

This reference page contains operations-related mini-guides and minor posts.

---

[TOC]

---

# Test MTU from Ubuntu

You would not believe the strange problems that an MTU issue can be the root cause of.

```bash
ping -M do -s 1472 <remote server>
ping -M do -s 8900 <remote server>
```

---

# Find big files on Mac OS

My SSD is always almost full. Here are useful commands for cleaning up:

```bash
# Find all the files over 1G
sudo find / -type f -size +1G -exec ls -lh {} \; | awk '{ print $9 ": " $5 }' 2>/dev/null

# List files in Downloads directory by size
ls -lhS ~/Downloads
```


# Renew NTP Lease Ubuntu

```bash
service ntp stop
ntpd -gq
service ntp start
```


---

# Create AWS ECR Registry If Not Found

```bash
aws ecr describe-repositories --repository-names $repo_name \
    || aws ecr create-repository --repository-name $repo_name
```


---


# Passwordless sudo on Ubuntu Server

Run `visudo` as root.

```bash
# as root
export EDITOR=vim
visudo
```

Add the user (replace `exampleUser`) at the end.

```text
exampleUser ALL=(ALL) NOPASSWD: ALL
```

For those who don't use vim, a quick reminder:
`i` enter to insert mode , `[esc]` to exit insert mode, `:wq` to save and quit.


---


# VIM Tasks

## Find & Replace

```bash
# replace findThis with ReplaceWithThis
:%s/findThis/ReplaceWithThis/g
```

## Spell-Check commands

```text
# enable/disable
:set spell spelllang=en_ca
:setlocal spell spelllang=en_ca
:set nospell

# next/last
]s
[s

# suggest change
z=

# add/remove word from dictionary
zg
zw`
```


---


# Use an Insecure Docker Registry
To use a registry with no HTTP cert:

`vi /etc/docker/daemon.json`

```json
{
    "insecure-registries" : ["myregistrydomain.com:5000"]
}
```


---


# Ansible ignore errors

The command is `ignore_errors: yes`

Just throw this into the task that's failing. It will still fail, but the play
won't stop.

Example:

```yml
- name: Ensure the docker service is running
  script: ../tools/validate-docker-execute.sh
    ignore_errors: yes
```


---


# How to tail -f on dmesg

```bash
dmesg -wH
```


---


# Ubuntu Downgrade a package

```bash
# Find the available versions under Versions:
apt-cache showpkg <package>

# Install one of those
apt-get install <package>=<version>
```


---


# Make Ansible run Python 3 on target nodes

Useful for OS that ship with python3 but not python2.
Edit the inventory, find a group of the groups and apply this var.

```ini
[baremetal:vars]
ansible_python_interpreter=/usr/bin/python3
```


---


# Bash: Print all but first line

Use `tail -n +2`.
This was unintuitive to me because +1 seems like it should do it.

```bash
# Example
docker images | awk '{print $3}' | tail -n +2
```


---


# Bash: Run code whenever a script exits

Use trap.
- [This is a nice post covering lots of examples](http://redsymbol.net/articles/bash-exit-traps/).
- [Here's where I first saw it used](https://github.com/GoogleCloudPlatform/endpoints-quickstart/blob/master/scripts/deploy_api.sh)

```bash
temp_file=$(mktemp)

cleanup() {
  rm "$temp_file"
}

trap cleanup EXIT
```
