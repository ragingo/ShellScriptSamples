#!/bin/bash

set -eu

cd "$(dirname "${BASH_SOURCE:-$0}")"
pwd

# shellcheck disable=SC1091
. ../lib/array.sh
# shellcheck disable=SC1091
. ../lib/math.sh
# shellcheck disable=SC1091
. ../lib/string.sh
# shellcheck disable=SC1091
. ./def.sh
# shellcheck disable=SC1091
. ./debug.sh


# 入力ファイル
readonly SRC_FILE_PATH=../../resources/catman.bmp
# 出力ファイル
readonly DST_FILE_PATH=./output.bmp

# 元データ (10進数の値がスペース区切りで並んでいる)
readonly SRC_DATA=$(bin_to_dec_str "$SRC_FILE_PATH" | trim_spaces)

# BITMAPFILEHEADER (10進数の値がスペース区切りで並んでいる)
BITMAPFILEHEADER_DATA=$(substr "$SRC_DATA" 0 "$BITMAPFILEHEADER_SIZE")
readonly BITMAPFILEHEADER_DATA

# BITMAPINFOHEADER (10進数の値がスペース区切りで並んでいる)
__offset="$BITMAPFILEHEADER_SIZE"
BITMAPINFOHEADER_DATA=$(substr "$SRC_DATA" "$__offset" "$BITMAPINFOHEADER_SIZE")
readonly BITMAPINFOHEADER_DATA

# 画像データ (10進数の値がスペース区切りで並んでいる)
__offset=$((__offset + BITMAPINFOHEADER_SIZE))
IMAGE_DATA=$(substr "$SRC_DATA" "$__offset" "")
readonly IMAGE_DATA

binarize() {
    local w=$1  # width
    local h=$2  # height
    local d=$3  # depth
    local img=$4
    local t=100 # threshold
    local src_img=()
    local dst_img=()

    split src_img "$img"
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

    local bfh=()
    split bfh "$BITMAPFILEHEADER_DATA"
    array_map bfh dec_to_bin

    local bih=()
    split bih "$BITMAPINFOHEADER_DATA"
    array_map bih dec_to_bin

    local IFS=""
    {
        echo -en "${bfh[*]}"
        echo -en "${bih[*]}"
        echo -en "${dst_img[*]}"
    } > "$DST_FILE_PATH"
}

# dump_bitmap_file_header "$BITMAPFILEHEADER_DATA"
# dump_bitmap_info_header "$BITMAPINFOHEADER_DATA"

binarize 32 32 3 "$IMAGE_DATA"
