title: Writing Blog Content for Pelican
summary: Steps and examples for writing web content to be consumed by Pelican
series: how-this-site-works
slug: htsw-3-write-pelican-post
category: gcp
tags: Pelican
date: 2019-08-03
modified: 2019-08-03
status: published


The goal is to have a collection of files stored on GitHub that represent the
raw content of a website. The content should be easy to write and maintain. It
will be transformed by Pelican into a website.

---

This guide is part of a series

1. [Building a Static Blog Site with Pelican and GCP](/htsw-1-intro.html)
1. [Build a pelican Docker image in the Google Container Registry](/htsw-2-pelican-image-gcr.html)
1. **[How to write Pelican blog content files](/htsw-3-write-pelican-post.html)**
1. [Hosting a Static Website on Google Cloud Storage](/htsw-4-gcs-static-website.html)
1. [Automatically rebuilding the site with Google Cloud-Build](/htsw-5-cloud-build-static-site.html)


---


# What is Pelican
[Pelican](https://github.com/getpelican/pelican) takes a collection of files
written in [Markdown](https://en.wikipedia.org/wiki/Markdown) as its input, and
outputs a full static blog website.


# Project Layout
The files should be placed in a structure as follows.

- Blog posts go in content/posts, and can be sorted into subdirectories.
- Static pages go in content/pages.
- output/ doesn't need to exist, but it is created by Pelican as a place to
  store the generated website files. It should alwys be empty in github.
```text
.
+-- content/
|   +-- posts/
|       +-- first.md
|       +-- how-this-site-works/
|           +-- how-this-site-is-made.md
|   +-- pages/
|       +-- about.md
+-- output/
```

# Pelican & Markdown Syntax Reference
## Post Metadata
The top of each post starts with some metadata that Pelican uses to scaffold
the site.
```text
title: Title of the post or page
summary: Detailed summary
slug: short-name-goes-in-the-url
category: whereThisWillBeSorted
date: 2019-08-28
modified: 2019-08-28
status: published or draft
```

## Headers
```text
Regular text
# Big header (h1)
## Smaller Header (h2)
### Even smaller header
```

## Horizontl Line
```text
---
```

## Table of Contents
\* depends on an extension\_config defined in pelicanconf.py of kylep/pelican
```text
[TOC]
```

## Numbered List
The numbers will automatically increment.
```test
1. First item
1. Second item
1. Third Item
```

## Bullet List
```text
- First Item
- Second Item
    - Nested List item with 4 spaces before the dash
- Third Item
```
---


# Preview the Site
The content is ready to be converted into a website. Use a Pelican container to
generate the site. The pelican container can also act as a local webserver to
preview changes before pushing them.

## Pull the Pelican Image
Pull a pelican imagefrom GCR or Docker Hub.
Mine is `gcr.io/kylepericak/pelican` on GCR and `kpericak/pelican` on Docker
Hub. The GCR image is private, since they charge me for the downloads.

```bash
docker pull gcr.io/kylepericak/pelican
# or
docker pull kpericak/pelican
```

## Launch the Pelican container
Run this from the project root. It will mount the content/ and output/
directories into a new container named "pelican". It will also forward the
port Pelican's webserver listens on (8000) to the workstation's port 8888.

The Pelican autoreload feature looks like maybe its multithreaded or something,
so running it as the root process of the docker container doesn't work.
Instead, launch the container with the `tail -f /dev/null` command so it just
idles.

```bash
docker run -d \
  --name pelican \
  -v $(pwd)/content:/content \
  -v $(pwd)/output:/output \
  -p 8888:8000 \
  gcr.io/kylepericak/pelican \
  tail -f /dev/null
```

## Launch the local webserver and auto-rebuild service
This will build the site files, launch the webserver, and watch for new
file changes so it can automatically rebuild.

The example `docker exec` command runs interactively. I like to run it in a
 dedicated tmux pane to show if anything has gone wrong.

```bash
docker exec -it pelican \
  pelican \
    -s /pelicanconf.py \
    --debug \
    --autoreload \
    --listen \
    /content \
    -o /output
```

## Browse to your site

[http://localhost:8888](http://localhost:8888)


---


# Reference Links
- [Offical Pelican Syntax Reference](http://docs.getpelican.com/en/3.6.3/content.html)


---


# Next Up
Now that the content is written, its time to
[host the static website on Google Cloud Storage](/htsw-4-gcs-static-website.html).
