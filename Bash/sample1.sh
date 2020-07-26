#!/bin/bash

set -eu

readonly WORK_DIR="$(dirname "${BASH_SOURCE:-$0}")"

include() {
    local target=$1
    local path="${WORK_DIR}/${target}"
    # shellcheck disable=SC1090
    . "$path"
}

include lib/ragingosh/include.sh
include lib/ragingosh/array.sh
include lib/ragingosh/map.sh
include lib/ragingosh/math.sh
include lib/ragingosh/string.sh

test_math() {
    # even, odd
    is_even 1 && echo "even" || echo "odd"
    is_even 2 && echo "even" || echo "odd"
    is_odd 3 && echo "odd" || echo "even"
    is_odd 4 && echo "odd" || echo "even"

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

    # fact
    fact 4
}

test_array() {
    local a=(1 2 3 4 5 6 7 8 9 10)
    array_filter a is_even
    echo "${a[@]}"
}

# shellcheck disable=SC2034
test_map() {
    local -A map=(
        ["a"]=1
        ["b"]=2
        ["c"]=3
    )
    map_keys map
    map_values map
    map_entry_count map
    map_contains_key map a
    map_contains_key map aa

    local a
    a=$(map_values map)
    local b=()
    split b "$a"
    local c
    c=$(sum b)
    echo "$c"
}

test_string() {
    c_to_i 'A'
    echo ""
    c_to_i 'B'
    echo ""
    i_to_c 65
    echo ""
    i_to_c 66
    echo ""
}

# test_array
# test_map
# test_math
test_string