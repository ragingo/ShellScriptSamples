#!/bin/bash

set -eu

# shellcheck disable=SC2010
# shellcheck disable=SC2046
dump() {
    local input_dir=$1

    pushd "$input_dir"

    ls -1d $(find .) | \
        grep -E "^.+\.mp4$" | \
        xargs -P4 -n2 -I% ffmpeg -i % 2>&1 | \
        grep -E "Input|Stream" > dump.txt

    popd
 }

 filter() {
    local input_dir=$1

    pushd "$input_dir"

    grep -E "Stream.+Video: h264" dump.txt -B1 | \
        grep -E "Input.+" | \
        sed -r "s/^Input.+from ['](.+\.mp4)[']:/\1/"

    popd
}

# dump "$@"
filter "$@"
