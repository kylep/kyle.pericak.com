title: Building a Static Blog Site with Pelican and GCP
summary: How this blog site was made
slug: how-this-site-is-made
tags: Pelican,GCP
category: guides
date: 2019-07-27
modified: 2019-08-01
status: published


This post covers how I built this site, [kyle.pericak.com](/).

---

# How it Works

## Website is hosted by Google Cloud Storage
GCS has a feature that lets you upload HTML files to a storage bucket named
after your domain. The storage bucket backing this site is called
`kyle.pericak.com`.

The `pericak.com` domain also has a CNAME for `kyle` pointing at an API url
hosted by Google, `storage.l.googleusercontent.com`, which directs traffic to
their web service.

The Google storage web service converts the web content files in GCS into a
functional website without ever requiring a dedicated web server.


## Content is written in Markdown, pushed to GitHub
Markdown is basically plain text, with a few extra features. It's very popular
and is used for GitHub readme.md files, among other uses. The posts are saved
to a public GitHub repository, in this case `kylep/kyle.pericak.com`.

A static site generator named Pelican is used to turn the blog content into a
websitee. Pelican accepts the markdown content files as input, and
programatically tansforms them into the posts and pages of a blog site. It
has customizable themes and plugins to enable features like embedding a table
of contents by writing `[TOC]`.


## Changes are automatically built and deployed using Google Cloud-Build
Pelican is built into a Docker image, where it can be ran interactively from a
workstation (Macbook) or automatically from Google Cloud-Build.

Google Cloud-Build is configured with a trigger to watch for changes to the
public GitHub repository `kylep/pelican`. When a change is deteced, it rebuilds
the pelican image and re-pushes it to the Google Container Registry.

Another trigger watches for both the `kylep/pelican` repository and also the
`kylep/kyle.pericak.com` repository, where the markdown blog content goes. When
the content or pelican image change, the markdown files are re-converted into
a website and uploaded to GCS. The GCS bucket is linked to the domain name.


# Guide Posts to Build This Site
1. [Build a pelican Docker image in the Google Container Registry](/build-pelican-image-gcr.html)
1. [Write and push blog content files to GitHub](/write-pelican-post.html)
1. [Hosting the site on Google Cloud Storage](/gcs-static-website.html)
1. [Automatically rebuilding the site with Google Cloud-Build](/cloud-build-static-site.html)


# Reference Links
- [Pelican image source code on GitHub](https://github.com/kylep/pelican)
- [Site content source code on GitHub](https://github.com/kylep/kyle.pericak.com)
- [ahmet.im - GCP Container builder + Pelican guide](https://ahmet.im/blog/using-google-cloud-storage-for-my-blog/)
