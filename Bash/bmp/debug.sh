#!/bin/bash

include_guard BMP_DEBUG_SH || return 0

dump_bitmap_file_header() {
    local -n __data=$1
    declare -A file_header=()
    parse_bitmap_file_header __data file_header

    echo "=== BITMAPFILEHEADER ==="

    for k in "${!file_header[@]}"; do
        case "$k" in
            "bfType" ) echo "$k: ${file_header[$k]}" ;;
            "bfSize" ) printf "%s: %'d\n" "$k" "${file_header[$k]}" ;;
            "bfReserved1" ) echo "$k: ${file_header[$k]}" ;;
            "bfReserved2" ) echo "$k: ${file_header[$k]}" ;;
            "bfOffBits" ) printf "%s: %'d\n" "$k" "${file_header[$k]}" ;;
        esac
    done
}

export -f dump_bitmap_file_header

dump_bitmap_info_header() {
    local -n __data=$1
    declare -A info_header=()
    parse_bitmap_info_header __data info_header

    echo "=== BITMAPINFOHEADER ==="

    for k in "${!info_header[@]}"; do
        case "$k" in
            "biSize" ) printf "%s: %'d\n" "$k" "${info_header[$k]}" ;;
            "biWidth" ) printf "%s: %'d\n" "$k" "${info_header[$k]}" ;;
            "biHeight" ) printf "%s: %'d\n" "$k" "${info_header[$k]}" ;;
            "biPlanes" ) echo "$k: ${info_header[$k]}" ;;
            "biBitCount" ) echo "$k: ${info_header[$k]}" ;;
            "biCompression" ) echo "$k: ${info_header[$k]}" ;;
            "biSizeImage" ) printf "%s: %'d\n" "$k" "${info_header[$k]}" ;;
            "biXPixPerMeter" ) echo "$k: ${info_header[$k]}" ;;
            "biYPixPerMeter" ) echo "$k: ${info_header[$k]}" ;;
            "biClrUsed" ) echo "$k: ${info_header[$k]}" ;;
            "biCirImportant" ) echo "$k: ${info_header[$k]}" ;;
        esac
    done
}

export -f dump_bitmap_info_header
