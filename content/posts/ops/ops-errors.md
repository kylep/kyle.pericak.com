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
