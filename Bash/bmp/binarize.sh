#!/bin/bash

include_guard BMP_BINARIZE_SH || return 0

# shellcheck disable=SC2034
binarize() {
    local w=$1  # width
    local h=$2  # height
    local d=$(($3 / 8))  # depth (一旦、ビットで来る前提にする)
    local t=$4  # threshold
    local -n __binarize_src_img=$5
    local -n __binarize_dst_img=$6

    array_fill __binarize_dst_img $((w * h * d)) "\x0"

    for ((i = 0; i < $((w * h * d)); i += d)) do
        # 1px 3byte 前提の実装になってる！また今度直そう。
        local r=${__binarize_src_img[$((i + 0))]}
        local g=${__binarize_src_img[$((i + 1))]}
        local b=${__binarize_src_img[$((i + 2))]}

        if [ "$r" -lt "$t" ] || \
           [ "$g" -lt "$t" ] || \
           [ "$b" -lt "$t" ]; then
            __binarize_dst_img[$((i + 0))]="\xff"
            __binarize_dst_img[$((i + 1))]="\xff"
            __binarize_dst_img[$((i + 2))]="\xff"
        fi
    done
}

export -f binarize
