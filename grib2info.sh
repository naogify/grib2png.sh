#!/bin/bash
set -e

IMG_WGRIB2="ghcr.io/naogify/wgrib2:latest"

usage() {
  echo "Usage: $0 INPUT.grib2"
  exit 1
}

[ $# -ne 1 ] && usage
INPUT="$1"

if [ ! -f "$INPUT" ]; then
  echo "Error: $INPUT not found."
  exit 2
fi

WORKDIR=$(pwd)

docker run --rm -v "$WORKDIR":/data $IMG_WGRIB2 /data/"$INPUT" -s
