#!/bin/bash

if [[ -v __INCLUDE_BMP_BINARIZE_SH ]]; then
    return
else
    readonly __INCLUDE_BMP_BINARIZE_SH=1
    export __INCLUDE_BMP_BINARIZE_SH
fi

# shellcheck disable=SC2034
binarize() {
    local w=$1  # width
    local h=$2  # height
    local d=$3  # depth
    local t=$4  # threshold
    local -n _src_img=$5
    local -n _dst_img=$6

    array_fill _dst_img $((w * h * d)) "\x0"

    for ((i = 0; i < $((w * h * d)); i += 3)) do
        local r=${_src_img[$((i + 0))]}
        local g=${_src_img[$((i + 1))]}
        local b=${_src_img[$((i + 2))]}

        if [ "$r" -lt "$t" ] || \
           [ "$g" -lt "$t" ] || \
           [ "$b" -lt "$t" ]; then
            _dst_img[$((i + 0))]="\xff"
            _dst_img[$((i + 1))]="\xff"
            _dst_img[$((i + 2))]="\xff"
        fi
    done
}

export -f binarize
