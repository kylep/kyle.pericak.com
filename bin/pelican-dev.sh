#!/usr/bin/env bash

if [[ "$(whoami)" != "root" ]]; then
  echo "ERROR: Need to run this as root"
  exit 1
fi

if [[ ! -d content || ! -f pelicanconf.py ]]; then
  echo "ERROR: content dir or pelicanconf.py not found. Run from  project root"
  exit 1
fi

# Optional Theme mount for theme development. Pass the root dir of theme as arg
template_mount=""
if [[ $# == 1 ]]; then
  template_dir=$1
  echo "Mounting $template_dir to /theme"
  template_mount="-v $template_dir:/theme"
fi

mkdir -p output
docker pull gcr.io/kylepericak/pelican
if [[ $(docker ps -a  | grep pelican) ]]; then
  docker rm -f pelican
fi
docker run -d $template_mount \
  --name pelican \
  -v $(pwd)/pelicanconf.py:/pelicanconf.py \
  -v $(pwd)/content:/content \
  -v $(pwd)/output:/output \
  -p 0.0.0.0:80:8000 \
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
