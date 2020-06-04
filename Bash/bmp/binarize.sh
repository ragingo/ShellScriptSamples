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

binarize() {
    local w=$1  # width
    local h=$2  # height
    local d=$3  # depth
    local -n src_img=$4
    local dst_img=()
    local t=100 # threshold

    array_fill dst_img $((w * h * d)) "\x0"

    for ((i = 0; i < $((w * h * d)); i += 3)) do
        local r=${src_img[$((i + 0))]}
        local g=${src_img[$((i + 1))]}
        local b=${src_img[$((i + 2))]}

        if [ "$r" -lt "$t" ] || \
           [ "$g" -lt "$t" ] || \
           [ "$b" -lt "$t" ]; then
            dst_img[$((i + 0))]="\xff"
            dst_img[$((i + 1))]="\xff"
            dst_img[$((i + 2))]="\xff"
        fi
    done

    array_map BITMAPFILEHEADER_DATA dec_to_bin
    array_map BITMAPINFOHEADER_DATA dec_to_bin

    local IFS=""
    {
        echo -en "${BITMAPFILEHEADER_DATA[*]}"
        echo -en "${BITMAPINFOHEADER_DATA[*]}"
        echo -en "${dst_img[*]}"
    } > "$DST_FILE_PATH"
}

# dump_bitmap_file_header "$BITMAPFILEHEADER_DATA"
# dump_bitmap_info_header "$BITMAPINFOHEADER_DATA"

binarize 32 32 3 IMAGE_DATA
