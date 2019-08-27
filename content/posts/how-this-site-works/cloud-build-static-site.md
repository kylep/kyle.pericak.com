title: Cloud Build: Automatically Building and Deploying This Site
summary: The steps followed to configure cloud-build triggers for my website.
slug: cloud-build-static-site
category: guides
date: 2019-08-27
modified: 2019-08-27
tags: pelican,docker,GCR,cloud-build
authors: Kyle Pericak
status: published


Deploying changes to Google Cloud Storage manually is well and good, but there
is a better way. Google Cloud-Builder can watch for changes to the GitHub repo
holding the files and automatically rebuild everything, then push the changes
up to GCS.


# Pre-Reqs

This guide assumes the following has already been completed:

1. [Build a pelican Docker image in the Google Container Registry](/build-pelican-image-gcr.html)
1. [Write and push blog content files to GitHub](/write-pelican-post.html)
1. [Hosting the site on Google Cloud Storage](/gcs-static-website.html)


# About Cloud-Build & cloudbuild.yaml
Google Cloud Build is a cloud service that works nicely with GCR and GitHub to
watch for changes and then run through automated tasks. The tasks it executes
are defined by the `cloudbuild.yaml` file.

There's a cloudbuild file in each of the GitHub projects.

## cloudbuild.yaml Reference

- [Google's Cloud-Build Documentation](https://cloud.google.com/cloud-build/docs/build-config)
- [Variables Available in cloudbuild.yaml](https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values)



# Automatically Building the Pelican Image

## Write the cloudbuild.yaml file
See [my cloudbuild file](https://github.com/kylep/pelican/blob/master/cloudbuild.yaml).

There are two keys: steps and images.

The `steps:` key uses `cloud-builders/docker` to invoke a `docker build`
command. It builds from the `Dockerfile` and tags the image. The variable
`$PROJECT_ID` is subtituted with the GCP project's ID when cloud-build runs.

The `images:` key defines which images to push to the Google Container
Registry. In this case, it pushes the just-built container.

## Build the Cloud-Build Trigger
This is done in the GCP web UI. The goal is to launch the cloud-build defined
by the `cloudbuild.yaml` file whenever a commit is pushed to the `stable`
branch of pelican GitHub repo.

1. Go to [Google Cloud-Build](https://console.cloud.google.com/cloud-build).
1. On the left side-bar, navigate to Triggers
1. Add Trigger
1. Select source: GitHub
1. Authenticate: Log in if needed
1. Select Repository: I chose `kylep/pelican`
1. Name: I used `pelicanPushToMaster`
1. Description: `Push to master branch`
1. Trigger Type: `Branch`
1. Branch: `master`
1. Build Configuration: `cloudbuild.yaml`
1. **Create Trigger**

With this trigger in place, all pushes to the pelican project will trigger the
rebuilding of its image, followed by updating the image in GCR with the latest
changes.


# Reference Links

- [Google's Cloud-Build Documentation](https://cloud.google.com/cloud-build/docs/build-config)
- [Variables Available in cloudbuild.yaml](https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values)
- [cloud-builder/docker Source Code on GitHub](https://github.com/GoogleCloudPlatform/cloud-builders/tree/master/docker)
