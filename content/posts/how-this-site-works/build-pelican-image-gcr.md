title: Containerizing Pelican in Google Container Registry
summary: Building a pelican Docker image and uploading to GCR for cloud-builder
slug: build-pelican-image-gcr
category: guides
date: 2019-08-27
modified: 2019-08-27
tags: pelican,docker,GCR,cloud-build
authors: Kyle Pericak
status: published


---

Pelican is a static website generator written in Python that can convert
markdown format text files into blog posts. This guide will install Pelican in
a Docker image and upload that image to the Google Container Registry for use
with the Google Cloud-Builder.

Anyone is welcome to use my Pelican image instead of building their own.
I share it on Docker Hub so I don't need to pay for public downloads from GCR.

- [Docker Hub kpericak/pelican](https://cloud.docker.com/u/kpericak/repository/docker/kpericak/pelican)

---

# Code on GitHub
Take a look at my code on GitHub. I'll explain it here, but there's no point
copying its content into this post.

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


## About the cloudbuild.yaml file

Here are some references regarding building a cloudbuild.yaml file

- [Google's Cloud-Build Documentation](https://cloud.google.com/cloud-build/docs/build-config)
- [Variables Available in cloudbuild.yaml](https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values)
- [cloud-builder/docker Source Code on GitHub](ttps://github.com/GoogleCloudPlatform/cloud-builders/tree/master/docker)

In my cloudbuild file, there are two keys: steps and images.

The `steps:` key uses `cloud-builders/docker` to invoke a `docker build`
command. It builds from the `Dockerfile` and tags the image. The variable
`$PROJECT_ID` is subtituted with the GCP project's ID when cloud-build runs.

The `images:` key defines which images to push to the Google Container
Registry. In this case, it pushes the just-built container.


## Build & Push the Image to GCR
To manually build your image and upload it to the GCR, run something like this:
```bash
gcloud builds submit --tag gcr.io/kylepericak/pelican:latest
```
