title: Docker Shared Memory (/dev/sdh)
description: Shared memory for Docker
slug: docker-shared-memory
category: docker
tags: docker
date: 2019-09-06
modified: 2019-09-06
status: draft


Docker supports shared memory. The default is only 64MB though which is TINY.


# Change the /dev/shm size on the system

```bash
mount -o remount,size=1G /dev/shm
```

# Update Docker Daemon's Default Shared Memory Size

/etc/docker/daemon.json

```json
{
  "default-shm-size": "512M"
}
```

# Set a Containers Shared Memory Size

```bash
docker run -it --shm-size=512M
```
