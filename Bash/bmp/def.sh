#!/bin/bash

if [[ -v __INCLUDE_BMP_DEF_SH ]]; then
    return
else
    readonly __INCLUDE_BMP_DEF_SH=1
    export __INCLUDE_BMP_DEF_SH
fi

# https://docs.microsoft.com/ja-jp/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
readonly BITMAPFILEHEADER_SIZE=$((2 + 4 + 2 + 2 + 4))
export BITMAPFILEHEADER_SIZE


# https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
readonly BITMAPINFOHEADER_SIZE=$((4 + 4 + 4 + 2 + 2 + 4 + 4 + 4 + 4 + 4 + 4))
export BITMAPINFOHEADER_SIZE
