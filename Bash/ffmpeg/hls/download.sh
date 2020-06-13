#!/bin/bash

readonly INPUT_DIR=./input
readonly OUTPUT_DIR=./output

readonly INPUT_FILE=master.m3u8
readonly OUTPUT_FILE=output.mp4

readonly PROTOCOLS=file,http,https,tcp,tls,crypto
readonly USERAGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"

download() {
    local map=$1
    local opt_protocol_whitelist=(-protocol_whitelist "$PROTOCOLS")
    local opt_i=(-i "$INPUT_DIR/$INPUT_FILE")
    local opt_c=(-c copy)
    local opt_useragent=(-user-agent \""$USERAGENT"\")
    local opt_map=()
    if [[ $map ]]; then
        opt_map=(-map p:"$map")
    fi

    ffmpeg \
        "${opt_protocol_whitelist[@]}" \
        "${opt_i[@]}" \
        "${opt_c[@]}" \
        "${opt_map[@]}" \
        "${opt_useragent[@]}" \
        "$OUTPUT_DIR/$OUTPUT_FILE"
}

download "$@"
