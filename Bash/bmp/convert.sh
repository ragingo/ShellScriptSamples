#!/bin/bash

set -eu

readonly WORK_DIR="$(dirname "${BASH_SOURCE:-$0}")"
cd "$WORK_DIR"

include() {
    local target=$1
    local path="${WORK_DIR}/${target}"
    # shellcheck disable=SC1090
    . "$path"
}

include ../lib/array.sh
include ../lib/math.sh
include ../lib/string.sh
include def.sh
include io.sh
include binarize.sh
include debug.sh

# 入力ファイル
readonly SRC_FILE_PATH=../../resources/catman.bmp

# 出力ファイル
readonly DST_FILE_PATH=./output.bmp

# 元データ (10進数の値がスペース区切りで並んでいる)
readonly SRC_DATA=$(bin_to_dec_str "$SRC_FILE_PATH" | trim_spaces)

# BITMAPFILEHEADER (10進数の値の配列に変換)
BITMAPFILEHEADER_STRING=$(substr "$SRC_DATA" 0 "$BITMAPFILEHEADER_SIZE")
readonly BITMAPFILEHEADER_STRING
BITMAPFILEHEADER_DATA=()
split BITMAPFILEHEADER_DATA "$BITMAPFILEHEADER_STRING"

# BITMAPINFOHEADER (10進数の値の配列に変換)
__offset="$BITMAPFILEHEADER_SIZE"
BITMAPINFOHEADER_STRING=$(substr "$SRC_DATA" "$__offset" "$BITMAPINFOHEADER_SIZE")
readonly BITMAPINFOHEADER_STRING
BITMAPINFOHEADER_DATA=()
split BITMAPINFOHEADER_DATA "$BITMAPINFOHEADER_STRING"

# 画像データ (10進数の値の配列に変換)
__offset=$((__offset + BITMAPINFOHEADER_SIZE))
IMAGE_STR=$(substr "$SRC_DATA" "$__offset" "")
readonly IMAGE_STR
IMAGE_DATA=()
split IMAGE_DATA "$IMAGE_STR"


# dump_bitmap_file_header "$BITMAPFILEHEADER_DATA"
# dump_bitmap_info_header "$BITMAPINFOHEADER_DATA"

output_data=()
binarize 32 32 3 100 IMAGE_DATA output_data

output_bmp_file "$DST_FILE_PATH" BITMAPFILEHEADER_DATA BITMAPINFOHEADER_DATA output_data
