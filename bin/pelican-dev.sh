#!/usr/bin/env bash
mkdir -p output
docker pull gcr.io/kylepericak/pelican
docker rm -f pelican >/dev/null || true
docker run -d \
  --name pelican \
  -v $(pwd)/content:/content \
  -v $(pwd)/output:/output \
  -p 8888:8000 \
  gcr.io/kylepericak/pelican \
  tail -f /dev/null

docker exec -it pelican \
  pelican \
    -s /pelicanconf.py \
    --debug \
    --autoreload \
    --listen \
    /content \
    -o /output
