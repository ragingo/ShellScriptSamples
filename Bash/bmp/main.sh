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

include ../lib/_.sh
include ../lib/array.sh
include ../lib/map.sh
include ../lib/math.sh
include ../lib/string.sh
include def.sh
include io.sh
include bmp.sh
include binarize.sh
include debug.sh

echo "included files"
included_files | tr ' ' '\n'
echo ""

# 入力ファイル
readonly SRC_FILE_PATH=../../resources/catman.bmp

# 出力ファイル
readonly DST_FILE_PATH=./output.bmp

# shellcheck disable=SC2034
main() {
    # ファイル全体のバイナリデータを取得
    local src_data=()
    bmp_file_load "$SRC_FILE_PATH" src_data

    # 各メタデータを取得
    declare -A file_header=()
    declare -A info_header=()
    bmp_meta_load src_data file_header info_header
    # map_entries file_header
    # map_entries info_header

    # 全ピクセル取得
    local pixels=()
    bmp_get_pixels src_data file_header pixels

    # 2値化
    local output_data=()
    binarize \
        "${info_header["biWidth"]}" \
        "${info_header["biHeight"]}" \
        "${info_header["biBitCount"]}" \
        100 \
        pixels output_data

    # ファイル出力
    bmp_file_save \
        "$DST_FILE_PATH" \
        "${info_header["biWidth"]}" \
        "${info_header["biHeight"]}" \
        "${info_header["biBitCount"]}" \
        output_data
}

main
