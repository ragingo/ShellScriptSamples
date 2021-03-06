#!/bin/bash

include_guard BMP_BMP_SH || return 0

calc_offsets() {
    local -n __calc_offsets_sizes=$1
    local -n __calc_offsets_offsets=$2
    local item_count=${#__calc_offsets_sizes[@]}

    array_fill __calc_offsets_offsets "$item_count" 0

    for ((i=0; i < "$item_count"; i++)) do
        if [ $i -gt 0 ]; then
            local prev_offset=${__calc_offsets_offsets[$((i - 1))]}
            local prev_size=${__calc_offsets_sizes[$((i - 1))]}
            local offset=$((prev_offset + prev_size))
            __calc_offsets_offsets[$i]=$offset
        else
            __calc_offsets_offsets[$i]=0
        fi
    done
}

export -f calc_offsets

# shellcheck disable=SC2034
bmp_parse_file_header() {
    local -n __bmp_parse_file_header_data=$1
    local -n __bmp_parse_file_header_map=$2
    local sizes=(2 4 2 2 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${__bmp_parse_file_header_data[*]:$idx:$len}"

        case "$i" in
            0 ) __bmp_parse_file_header_map["bfType"]="$(echo "$val" | awk '{ printf("%c%c", $1, $2) }')" ;;
            1 ) __bmp_parse_file_header_map["bfSize"]="$(u8x4_string_to_u32 "$val")" ;;
            2 ) __bmp_parse_file_header_map["bfReserved1"]="$val" ;;
            3 ) __bmp_parse_file_header_map["bfReserved2"]="$val" ;;
            4 ) __bmp_parse_file_header_map["bfOffBits"]="$(u8x4_string_to_u32 "$val")" ;;
        esac
    done
}

export -f bmp_parse_file_header

# shellcheck disable=SC2034
bmp_parse_info_header() {
    local -n __bmp_parse_info_header_data=$1
    local -n __bmp_parse_info_header_map=$2
    local sizes=(4 4 4 2 2 4 4 4 4 4 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${__bmp_parse_info_header_data[*]:$idx:$len}"

        case "$i" in
            0 ) __bmp_parse_info_header_map["biSize"]="$(u8x4_string_to_u32 "$val")" ;;
            1 ) __bmp_parse_info_header_map["biWidth"]="$(u8x4_string_to_u32 "$val")" ;;
            2 ) __bmp_parse_info_header_map["biHeight"]="$(u8x4_string_to_u32 "$val")" ;;
            3 ) __bmp_parse_info_header_map["biPlanes"]="$(u8x2_string_to_u32 "$val")" ;;
            4 ) __bmp_parse_info_header_map["biBitCount"]="$(u8x2_string_to_u32 "$val")" ;;
            5 ) __bmp_parse_info_header_map["biCompression"]="$(u8x4_string_to_u32 "$val")" ;;
            6 ) __bmp_parse_info_header_map["biSizeImage"]="$(u8x4_string_to_u32 "$val")" ;;
            7 ) __bmp_parse_info_header_map["biXPixPerMeter"]="$(u8x4_string_to_u32 "$val")" ;;
            8 ) __bmp_parse_info_header_map["biYPixPerMeter"]="$(u8x4_string_to_u32 "$val")" ;;
            9 ) __bmp_parse_info_header_map["biClrUsed"]="$(u8x4_string_to_u32 "$val")" ;;
            10 ) __bmp_parse_info_header_map["biCirImportant"]="$(u8x4_string_to_u32 "$val")" ;;
        esac
    done
}

export -f bmp_parse_info_header

# shellcheck disable=SC2034
bmp_meta_load() {
    local -n __bmp_meta_load_data=$1
    local -n __bmp_meta_load_file_header=$2
    local -n __bmp_meta_load_info_header=$3

    # BITMAPFILEHEADER
    local file_header_data=("${__bmp_meta_load_data[@]:0:$BITMAPFILEHEADER_SIZE}")
    bmp_parse_file_header file_header_data __bmp_meta_load_file_header

    # BITMAPINFOHEADER
    local offset="$BITMAPFILEHEADER_SIZE"
    local info_header_data=("${__bmp_meta_load_data[@]:$offset:$BITMAPINFOHEADER_SIZE}")
    bmp_parse_info_header info_header_data __bmp_meta_load_info_header
}

export -f bmp_meta_load

# shellcheck disable=SC2034
bmp_get_pixels() {
    local -n __bmp_get_pixels_data=$1
    local -n __bmp_get_pixels_file_header=$2
    local -n __bmp_get_pixels_pixels=$3

    # 画像データ
    local offset="${__bmp_get_pixels_file_header["bfOffBits"]}"
    __bmp_get_pixels_pixels=("${__bmp_get_pixels_data[@]:$offset}")
}

export -f bmp_get_pixels

bmp_make_file_header() {
    local -n __bmp_make_file_header_output=$1
    local file_size=$2

    local size=()
    u32_to_u8x4 "$file_size" size

    local offset=()
    u32_to_u8x4 "$((BITMAPFILEHEADER_SIZE + BITMAPINFOHEADER_SIZE))" offset

    __bmp_make_file_header_output+=(66 77)
    __bmp_make_file_header_output+=("${size[@]}")
    __bmp_make_file_header_output+=(0 0)
    __bmp_make_file_header_output+=(0 0)
    __bmp_make_file_header_output+=("${offset[@]}")
}

export -f bmp_make_file_header

bmp_make_info_header() {
    local -n __bmp_make_info_header_output=$1
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

    __bmp_make_info_header_output+=("${header_size[@]}")
    __bmp_make_info_header_output+=("${w[@]}")
    __bmp_make_info_header_output+=("${h[@]}")
    __bmp_make_info_header_output+=(1 0)
    __bmp_make_info_header_output+=("$_bits" 0)
    __bmp_make_info_header_output+=(0 0 0 0)
    __bmp_make_info_header_output+=("${image_size[@]}")
    __bmp_make_info_header_output+=(0 0 0 0)
    __bmp_make_info_header_output+=(0 0 0 0)
    __bmp_make_info_header_output+=(0 0 0 0)
    __bmp_make_info_header_output+=(0 0 0 0)
}

export -f bmp_make_info_header
