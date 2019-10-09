title: Containerizing Pelican in Google Container Registry
summary: Building a pelican Docker image and uploading to GCR for cloud-builder
series: how-this-site-works
series_index: 2
slug: htsw-2-pelican-image-gcr
category: gcp
tags: Pelican,GCP
date: 2019-08-01
modified: 2019-08-01
authors: Kyle Pericak
status: published


Pelican is a static website generator written in Python that can convert
markdown format text files into blog posts. This guide will install Pelican in
a Docker image and upload that image to the Google Container Registry for use
with the Google Cloud-Builder.

Anyone is welcome to use my Pelican image instead of building their own.
I share it on Docker Hub so I don't need to pay for public downloads from GCR.

- [Docker Hub kpericak/pelican](https://cloud.docker.com/u/kpericak/repository/docker/kpericak/pelican)

---

This guide is part of a series

1. [Building a Static Blog Site with Pelican and GCP](/htsw-1-intro.html)
1. **[Build a pelican Docker image in the Google Container Registry](/htsw-2-pelican-image-gcr.html)**
1. [How to write Pelican blog content files](/htsw-3-write-pelican-post.html)
1. [Hosting a Static Website on Google Cloud Storage](/htsw-4-gcs-static-website.html)
1. [Automatically rebuilding the site with Google Cloud-Build](/htsw-5-cloud-build-static-site.html)


---


# My Code on GitHub
Take a look at my code on GitHub. I'll explain it in this post.

- [My GitHub repo for the Pelican Docker image](https://github.com/kylep/pelican)


## What Each File is For

- The utility scripts in `bin/` can be ignored.
- The cloudbuild.yaml file is [explained here](/cloud-build-static-site.html)

```text
Dockerfile       - Contains the code to build the image. Installs pelican and
                   the contents of requirements.txt

pelicanconf.py   - Configuration file for Pelican to use. This is my config
                   but if anyone wants to use this image they can copy/mount
                   their own to the container post-build.

requirements.txt - List of python packages to install for Pelican and plugins

cloudbuild.yaml  - Instructions for Google Cloud-Builder
```

### Dockerfile
To build the pelican image:

1. The pelican config file and requirements.txt are copied into the image
1. Software dependencies such as git and pip are installed
1. The packages listed in requirements.txt are installed
1. My fork of pelican-themes is cloned. A fork isn't needed, but prevents any
   unplanned changes to the theme I choose. Eventually I'll probably write my
   own.


### cloudbuild.yaml

Here are some references regarding building a cloudbuild.yaml file

- [Google's Cloud-Build Documentation](https://cloud.google.com/cloud-build/docs/build-config)
- [Variables Available in cloudbuild.yaml](https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values)
- [cloud-builder/docker Source Code on GitHub](ttps://github.com/GoogleCloudPlatform/cloud-builders/tree/master/docker)

There are two keys: `steps` and `images`.

The `steps:` key contains a list of tasks to be executed by cloud-builder.
This file contains one task, which uses the `cloud-builders/docker` docker
imageto invoke a `docker build` command. The docker build command works like
the usual docker client would - it builds from the `Dockerfile` and tags the
image. The variable `$PROJECT_ID` is subtituted with the GCP project's ID when
cloud-build runs.

The `images:` key defines a list of images to push to the Google Container
Registry. In this case, it pushes the new pelican container.


## Build & Push the Image to GCR
To manually build your image and upload it to the GCR, run something like this:
```bash
gcloud builds submit --tag gcr.io/kylepericak/pelican:latest
```


---


# Next Up
Now a Pelican image is built, its time to write some content. Check out my next
post, [How to write and push blog content files to GitHub](/htsw-3-write-pelican-post.html)
