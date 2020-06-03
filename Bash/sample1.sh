#!/bin/bash

set -eu

readonly WORK_DIR="$(dirname "${BASH_SOURCE:-$0}")"

include() {
    local target=$1
    local path="${WORK_DIR}/${target}"
    # shellcheck disable=SC1090
    . "$path"
}

include lib/array.sh
include lib/math.sh
include lib/string.sh

is_odd() {
    if [[ $(("$1" & 1)) -eq 1 ]]; then
        true
    else
        false
    fi
}

is_even() {
    if [[ $(("$1" & 1)) -eq 0 ]]; then
        true
    else
        false
    fi
}

test_math() {
    # pow
    pow 2 8
    pow 10 3

    # sum
    local a=(1 2 3 4 5 6 7 8 9 10)
    local r
    r=$(sum a)
    echo "$r"
    r=$(sum a is_odd)
    echo "$r"
}

test_array() {
    local a=(1 2 3 4 5 6 7 8 9 10)
    array_filter a is_even
    echo "${a[@]}"
}

test_math
test_array
