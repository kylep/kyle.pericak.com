#!/usr/bin/env bash

# Optional Theme mount for theme development. Pass the root dir of theme as arg
template_mount=""
if [[ $# == 1 ]]; then
  template_dir=$1
  echo "Mounting $template_dir to /theme"
  template_mount="-v $template_dir:/theme"
fi

mkdir -p output
docker pull gcr.io/kylepericak/pelican
docker rm -f pelican >/dev/null || true
docker run -d $template_mount \
  --name pelican \
  -v $(pwd)/content:/content \
  -v $(pwd)/output:/output \
  -p 0.0.0.0:8000:8000 \
  gcr.io/kylepericak/pelican \
  tail -f /dev/null

docker exec -it pelican \
  pelican \
    -s /pelicanconf.py \
    --debug \
    --autoreload \
    --listen \
    --port 8000 \
    --bind 0.0.0.0 \
    /content \
    -o /output
