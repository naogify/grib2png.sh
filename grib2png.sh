#!/bin/bash
set -e

IMG_WGRIB2="ghcr.io/naogify/wgrib2:latest"
IMG_GDAL="osgeo/gdal:alpine-small-3.6.3"

usage() {
  echo "Usage: $0 INPUT.grib2 -o OUTPUT.png -u U_MATCH -v V_MATCH"
  echo "  入力ファイルは最初の引数、U/V成分（wgrib2のパターン）は必須です"
  exit 1
}

# 入力ファイル（位置引数1）
if [[ $# -lt 1 ]]; then
  usage
fi
INPUT="$1"
shift

# オプション
while [[ $# -gt 0 ]]; do
  case $1 in
    -o) OUTPUT="$2"; shift 2 ;;
    -u) U_MATCH="$2"; shift 2 ;;
    -v) V_MATCH="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[ -z "$INPUT" ] && usage
[ -z "$OUTPUT" ] && usage
[ -z "$U_MATCH" ] && usage
[ -z "$V_MATCH" ] && usage

WORKDIR=$(pwd)
TMP_UU=$(mktemp -u XXXX)
TMP_U="tmp_${TMP_UU}_u.grib2"
TMP_V="tmp_${TMP_UU}_v.grib2"
TMP_VRT="tmp_${TMP_UU}_bands.vrt"

# 1. U/V抽出
docker run --rm -v "$WORKDIR":/data $IMG_WGRIB2 /data/"$INPUT" -match "$U_MATCH" -grib_out /data/"$TMP_U"
docker run --rm -v "$WORKDIR":/data $IMG_WGRIB2 /data/"$INPUT" -match "$V_MATCH" -grib_out /data/"$TMP_V"

# 2. VRT合成 (R=U, G=V, B=V)
docker run --rm -v "$WORKDIR":/data $IMG_GDAL \
  gdalbuildvrt -separate /data/"$TMP_VRT" /data/"$TMP_U" /data/"$TMP_V" /data/"$TMP_V"

# 3. PNG変換
docker run --rm -v "$WORKDIR":/data $IMG_GDAL \
  gdal_translate -ot Byte -scale -128 127 0 255 /data/"$TMP_VRT" /data/"$OUTPUT"

# 4. 一時ファイル削除
rm -f "$TMP_U" "$TMP_V" "$TMP_VRT"

echo "Done! Output: $OUTPUT"
