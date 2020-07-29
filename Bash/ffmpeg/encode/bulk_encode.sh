#!/bin/bash

get_hash() {
    local file=$1
    head -c 1M "$file" | md5sum | cut -d' ' -f1
}

export -f get_hash


readonly BASH_SRC_DIR="$(dirname "${BASH_SOURCE:-$0}")"

# shellcheck disable=SC1090
source "$BASH_SRC_DIR/../../lib/ragingosh/bash/src/include.sh"
include "$BASH_SRC_DIR/../../lib/ragingosh/bash/src/io.sh"
include "$BASH_SRC_DIR/../metadata/codec.sh"
include "$BASH_SRC_DIR/../encode/encode.sh"


encode() {
    local filelist=$1
    for f in $filelist; do
        local name
        name="$(get_basename "$f")"

        local parent_dir
        parent_dir="$dst_path/$(get_basename "$(get_dirname "$f")")"

        local output_file_path="$parent_dir/$name"

        mkdir -p "$parent_dir"
        to_h265 "$f" "$output_file_path"
    done
}

create_record() {
    local inum=$1

    local filename
    filename=$(get_abs_file_path_from_inum "$inum")

    local codecname
    codecname=$(get_codec_name "$filename")

    local checksum
    checksum=$(get_hash "$filename")

    echo "$inum $filename $codecname $checksum"
}

export -f create_record

get_filename_col() {
    local rec=$1
    echo "$rec" | cut -d' ' -f2
}

bulk_encode() {
    local src_path=$1
    local dst_path=$2

    # shellcheck disable=SC2164
    pushd "$dst_path"

    # "inode ファイル名" の一覧取得
    # shellcheck disable=SC2046
    local filelist
    filelist=$(find "$src_path" -type f -name '*.mp4' -printf '%i %p\n')

    # 最新のinode一覧作成
    echo "$filelist" | cut -d' ' -f1 > "$src_path/inode_list.txt"

    # メタデータ取得対象のチェック
    local not_encoded_inums
    if [[ -e "$src_path/encoded_inode_list.txt" ]]; then
        not_encoded_inums=$(diff "$src_path/inode_list.txt" "$src_path/encoded_inode_list.txt" | grep -E "^< [0-9]+$" | cut -d' ' -f2)
    else
        not_encoded_inums=$(echo "$filelist" | cut -d' ' -f1)
    fi

    # "inode ファイル名 codec名 checksum" の一覧取得
    # ffprobe が時間かかるから、6プロセス並列で実行する
    # shellcheck disable=SC2016
    local records
    records=$( \
        echo "$not_encoded_inums" | \
        xargs -P6 -n3 -I% bash -c 'create_record "%"' 2>&1 \
    )

    # "h264" でフィルタ
    local h264_records
    h264_records=$(echo "$records" | awk '{ if($3 == "h264") { print $0 } }')

    # エンコード対象のファイル名一覧取得
    local encode_targets
    encode_targets=$(get_filename_col "$h264_records")

    # エンコード
    encode "$encode_targets"

    # エンコード済みinode一覧
    mv "$src_path/inode_list.txt" "$src_path/encoded_inode_list.txt"

    # shellcheck disable=SC2164
    popd
}

export -f bulk_encode
