#!/bin/bash

include_guard BMP_IO_SH || return 0

output_bmp_file() {
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

export -f output_bmp_file
