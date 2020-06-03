#!/bin/bash

# https://docs.microsoft.com/ja-jp/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
declare -Ar BITMAPFILEHEADER_FIELDS=(
    ["bfType"]=2
    ["bfSize"]=4
    ["bfReserved1"]=2
    ["bfReserved1"]=2
    ["bfOffBits"]=4
)
export BITMAPFILEHEADER_FIELDS

readonly BITMAPFILEHEADER_SIZE=$((2 + 4 + 2 + 2 + 4))
export BITMAPFILEHEADER_SIZE


# https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
readonly BITMAPINFOHEADER_SIZE=$((4 + 4 + 4 + 2 + 2 + 4 + 4 + 4 + 4 + 4 + 4))
export BITMAPINFOHEADER_SIZE
