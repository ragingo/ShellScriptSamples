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

# 元データ (10進数の値の配列に変換)
readonly SRC_STRING=$(bin_to_dec_str "$SRC_FILE_PATH" | trim_spaces)
SRC_DATA=()
split SRC_DATA "$SRC_STRING"


# BITMAPFILEHEADER
# shellcheck disable=SC2034
BITMAPFILEHEADER_DATA=("${SRC_DATA[@]:0:$BITMAPFILEHEADER_SIZE}")

# dump_bitmap_file_header BITMAPFILEHEADER_DATA


# BITMAPINFOHEADER
__offset="$BITMAPFILEHEADER_SIZE"
# shellcheck disable=SC2034
BITMAPINFOHEADER_DATA=("${SRC_DATA[@]:$__offset:$BITMAPINFOHEADER_SIZE}")

# dump_bitmap_info_header BITMAPINFOHEADER_DATA


# 画像データ
__offset=$((__offset + BITMAPINFOHEADER_SIZE))
# shellcheck disable=SC2034
IMAGE_DATA=("${SRC_DATA[@]:$__offset}")


# 2値化
# shellcheck disable=SC2034
output_data=()
binarize 32 32 3 100 IMAGE_DATA output_data


# ファイル出力
output_bmp_file "$DST_FILE_PATH" BITMAPFILEHEADER_DATA BITMAPINFOHEADER_DATA output_data
