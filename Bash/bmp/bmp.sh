#!/bin/bash

include_guard BMP_BMP_SH || return 0

calc_offsets() {
    local -n _sizes=$1
    local -n _offsets=$2
    local item_count=${#_sizes[@]}

    array_fill _offsets "$item_count" 0

    for ((i=0; i < "$item_count"; i++)) do
        if [ $i -gt 0 ]; then
            local prev_offset=${_offsets[$((i - 1))]}
            local prev_size=${_sizes[$((i - 1))]}
            local offset=$((prev_offset + prev_size))
            _offsets[$i]=$offset
        else
            _offsets[$i]=0
        fi
    done
}

export -f calc_offsets

# shellcheck disable=SC2034
bmp_parse_file_header() {
    local -n _data=$1
    local -n _map=$2
    local sizes=(2 4 2 2 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${_data[*]:$idx:$len}"

        case "$i" in
            0 ) _map["bfType"]="$(echo "$val" | awk '{ printf("%c%c", $1, $2) }')" ;;
            1 ) _map["bfSize"]="$(u8x4_string_to_u32 "$val")" ;;
            2 ) _map["bfReserved1"]="$val" ;;
            3 ) _map["bfReserved2"]="$val" ;;
            4 ) _map["bfOffBits"]="$(u8x4_string_to_u32 "$val")" ;;
        esac
    done
}

export -f bmp_parse_file_header

# shellcheck disable=SC2034
bmp_parse_info_header() {
    local -n _data=$1
    local -n _map=$2
    local sizes=(4 4 4 2 2 4 4 4 4 4 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${_data[*]:$idx:$len}"

        case "$i" in
            0 ) _map["biSize"]="$(u8x4_string_to_u32 "$val")" ;;
            1 ) _map["biWidth"]="$(u8x4_string_to_u32 "$val")" ;;
            2 ) _map["biHeight"]="$(u8x4_string_to_u32 "$val")" ;;
            3 ) _map["biPlanes"]="$(u8x2_string_to_u32 "$val")" ;;
            4 ) _map["biBitCount"]="$(u8x2_string_to_u32 "$val")" ;;
            5 ) _map["biCompression"]="$(u8x4_string_to_u32 "$val")" ;;
            6 ) _map["biSizeImage"]="$(u8x4_string_to_u32 "$val")" ;;
            7 ) _map["biXPixPerMeter"]="$(u8x4_string_to_u32 "$val")" ;;
            8 ) _map["biYPixPerMeter"]="$(u8x4_string_to_u32 "$val")" ;;
            9 ) _map["biClrUsed"]="$(u8x4_string_to_u32 "$val")" ;;
            10 ) _map["biCirImportant"]="$(u8x4_string_to_u32 "$val")" ;;
        esac
    done
}

export -f bmp_parse_info_header

# shellcheck disable=SC2034
bmp_meta_load() {
    local -n _data=$1
    local -n _file_header=$2
    local -n _info_header=$3

    # BITMAPFILEHEADER
    local file_header_data=("${_data[@]:0:$BITMAPFILEHEADER_SIZE}")
    bmp_parse_file_header file_header_data file_header

    # BITMAPINFOHEADER
    __offset="$BITMAPFILEHEADER_SIZE"
    local info_header_data=("${_data[@]:$__offset:$BITMAPINFOHEADER_SIZE}")
    bmp_parse_info_header info_header_data info_header
}

export -f bmp_meta_load

# shellcheck disable=SC2034
bmp_get_pixels() {
    local -n _data=$1
    local -n _file_header=$2
    local -n _pixels=$3

    # 画像データ
    local offset="${_file_header["bfOffBits"]}"
    _pixels=("${_data[@]:$offset}")
}

export -f bmp_get_pixels

bmp_make_file_header() {
    local -n _output=$1
    local file_size=$2

    local size=()
    u32_to_u8x4 "$file_size" size

    local offset=()
    u32_to_u8x4 "$((BITMAPFILEHEADER_SIZE + BITMAPINFOHEADER_SIZE))" offset

    _output+=(66 77)
    _output+=("${size[@]}")
    _output+=(0 0)
    _output+=(0 0)
    _output+=("${offset[@]}")
}

export -f bmp_make_file_header

bmp_make_info_header() {
    local -n _output=$1
    local _w=$2
    local _h=$3
    local _bits=$4

    local header_size=()
    u32_to_u8x4 "$BITMAPINFOHEADER_SIZE" header_size

    local w=()
    u32_to_u8x4 "$_w" w

    local h=()
    u32_to_u8x4 "$_h" h

    local d="$((_bits / 8))"
    local image_size=()
    u32_to_u8x4 "$((_w * _h * d))" image_size

    _output+=("${header_size[@]}")
    _output+=("${w[@]}")
    _output+=("${h[@]}")
    _output+=(1 0)
    _output+=("$_bits" 0)
    _output+=(0 0 0 0)
    _output+=("${image_size[@]}")
    _output+=(0 0 0 0)
    _output+=(0 0 0 0)
    _output+=(0 0 0 0)
    _output+=(0 0 0 0)
}

export -f bmp_make_info_header
