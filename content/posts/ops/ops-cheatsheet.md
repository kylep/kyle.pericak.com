title: Operations Cheatsheet
description: Reference page for ops stuff
slug: ops-cheatsheet
category: operations
tags: ops, cheatsheet
date: 2019-09-11
modified: 2019-09-11
status: published


---


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

Run visudo as root.

```bash
# as root
export EDITOR=vim
visudo
```

Add the user (replace exampleUser) at the end.

```text
exampleUser ALL=(ALL) NOPASSWD: ALL
```

For those who don't use vim, a quick reminder:
`i` enter to insertmode , `[esc]` to exit insert mode, `:wq` to save and quit.


---


# VIM Tasks

## Find & Replace

```bash
# replace findThis with ReplaceWithThis
:%s/findThis/ReplaceWithThis/g
```
