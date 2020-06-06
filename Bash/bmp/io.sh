#!/bin/bash

include_guard BMP_IO_SH || return 0

# shellcheck disable=SC2034
bmp_file_load() {
    local path=$1
    local -n _data=$2

    # 元データ (10進数の値の配列に変換)
    local str
    str=$(bin_to_dec_str "$path" | trim_spaces)

    split _data "$str"
}

export -f bmp_file_load

bmp_file_save() {
    local path=$1
    local -n _bfh=$2
    local -n _bih=$3
    local -n _data=$4

    array_map _bfh dec_to_bin
    array_map _bih dec_to_bin

    local IFS=""
    {
        echo -en "${_bfh[*]}"
        echo -en "${_bih[*]}"
        echo -en "${_data[*]}"
    } > "$path"
}

export -f bmp_file_save
