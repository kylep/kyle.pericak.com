title: Pelican Guide
slug: pelican-guide
category: guide
date: 2019-07-27
modified: 2019-08-01

# Pelican guide
This guide covers the code used to generate this site, kyle.pericak.com.

I used a static code generator called [Pelican](https://github.com/getpelican/pelican).


## References
1. [guide from fullstackpython.com](https://www.fullstackpython.com/blog/generating-static-websites-pelican-jinja2-markdown.html)


## A static site
This is a static website. There's no javascript running.

The advantages of a static site are that they're lightweight/portable,
work well with a CDNs, and are simple to independently operate.

Also, they can be cheaper and easier to host on the public cloud.


# Starting new pelican app
## autogen the basics
### Create a python 3 virtual environment
```
python3 -m venv staticsite
```

### Install required software
Write a `setup.py` file for setuptools to track your dependencies.
[*TODO* Link to example setuptools file](about:blank)

From the directory holding the `setup.py` file, use pip to install the
dependencies.
```
pip install -U .
```


## Launch the dev server
The Makefile placed in kyle.pericak.com/ will be executable by the 'make'
command. Use it to launch the dev server.
```
make devserver
```

## Create content files
In `/content/posts`, make files ending in `.markdown`.
Write the files using Markdown syntax. These files are your content.

Each file also needs to start with some metadata for Pelican to parse.
Each file should have these few lines, with values appropriate for their post.
```
title: Pelican Guide
slug: pelican-guide
category: guide
date: 2019-07-27
modified: 2019-08-01
```

Pelican will use these values when generating the site.

[*TODO* Here's what this content file looks like](about:blank)

