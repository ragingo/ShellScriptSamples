#!/bin/bash

to_h265() {
    local input_file_path=$1
    local output_file_path=$2

    ffmpeg \
        -hwaccel cuda \
        -hwaccel_output_format cuda \
        -i "$input_file_path" \
        -preset fast \
        -rc vbr_hq \
        -vb 1.2M \
        -c:v hevc_nvenc \
        "$output_file_path"
}

export -f to_h265
