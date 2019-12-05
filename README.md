# kyle.pericak.com
Source code for my blog/tutorial site

# How this was made
[See here](http://kyle.pericak.com/blog-website.html)


# Launch Dev Webserver & Pelican Auto-Rebuild
This will launch a pelican container that mounts ./content and ./output. It
will generate the html in ./output, and regen it on every change to a .md file
in ./content.
```bash
bin/pelican-dev.sh
```
