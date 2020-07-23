#!/bin/bash

set -eu

 get_codec_name() {
    local input_path=$1
    ffprobe \
        -v quiet \
        -select_streams v:0 \
        -show_entries stream=codec_name \
        -of default=nokey=1:nw=1 \
        -hide_banner \
        "$input_path"
}

export -f get_codec_name

# shellcheck disable=SC2010
# shellcheck disable=SC2016
# shellcheck disable=SC2046
dump() {
    local input_dir=$1

    pushd "$input_dir"

    find $(pwd) -type f | \
        grep -E "^.+\.mp4$" | \
        xargs -P6 -n3 -I% bash -c 'name="$(get_codec_name %)"; echo "% $name"' 2>&1

    popd
 }

dump "$@"
