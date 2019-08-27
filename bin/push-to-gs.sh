#!/usr/bin/env bash
if [ ! -f output/index.html ]; then
  echo "No output files found. Run ./local-build.sh ?"
  exit
fi

# Run the gsutil rsync module to upload files to GCS
# -r    recurse - sync directories
# -c    compare checksums instead of mtime
# -d    Delete extra files under dst_url not found under src_url
src_url="./output"
dst_url="gs://kyle.pericak.com"
gsutil -m rsync -r -c -d $src_url $dst_url
