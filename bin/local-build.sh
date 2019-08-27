#!/usr/bin/env bash
docker pull gcr.io/kylepericak/pelican
docker rm -f pelican >/dev/null || true
docker run \
  --name pelican \
  -v $(pwd)/content:/content \
  -v $(pwd)/output:/output \
  pelican -s /pelicanconf.py /content -o /output
docker rm -f pelican >/dev/null || true
