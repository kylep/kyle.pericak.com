title: Operations: Error Codes
description: Error codes and how to fix them
slug: ops-errors
category: operations
tags: ops, cheatsheet
date: 2019-09-11
modified: 2019-09-11
status: published


---

# Failed command: aws ecr get-login

This error:
```
An error occurred (InvalidSignatureException) when calling the GetAuthorizationToken operation: Signature expired: 20190911T174538Z is now earlier than 20190912T004835Z (20190912T010335Z - 15 min.)
```

was caused by a bad NTP config. Renew the NTP lease to fix it.


---


# Pure Storage iSCSI with Kolla Openstack - fdisk freezes
This was a weird one. When using the Kolla containers project to make a
Cinder-volume container that has the purecinder plugin, I was able to get
OpenStack to create the volumes in Pure but it couldn't mount them to the hosts
for things like creating a volume with the `--image` argument. That made the
volumes I could create basically useless.

These errors were in the logs:
```text
# Lots of these in cinder's log
Trying to connect to iSCSI portal

# also from cinder's log, also recurring:
iscsiadm stderr output when getting sessions: iscsiadm: No active sessions

# in DMESG
FAILED Result: hostbyte=DID_NO_CONNECT driverbyte=DRIVER_OK
```

The weirdest part was that the `fdisk -l` command would totally lock up and
the process running it couldn't be killed even with `kill -9`. The iscsi volume
never got properly mounted but Pure support said they could see some data
coming into it.

**Root cause**: MTU mismatch. Of course. I had set MTU 9000 on the iSCSI ports,
my host ports, and the switchports heading to the Pure Storage iSCSI
interfaces. I had forgotten to set it on the swtich heading to the Dell servers
being used for OpenStack.


---
