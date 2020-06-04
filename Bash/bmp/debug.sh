#!/bin/bash

if [[ -v __INCLUDE_BMP_DEBUG_SH ]]; then
    return
else
    readonly __INCLUDE_BMP_DEBUG_SH=1
    export __INCLUDE_BMP_DEBUG_SH
fi

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

# shellcheck disable=SC2034
parse_bitmap_file_header() {
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

export -f parse_bitmap_file_header

dump_bitmap_file_header() {
    local -n _data=$1
    local sizes=(2 4 2 2 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${_data[*]:$idx:$len}"

        case "$i" in
            0 )
                echo "$val" | awk '{ printf("type: %c%c\n", $1, $2) }'
                ;;
            1 )
                printf "size: %'d B\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            2 | 3)
                echo "reserved"
                ;;
            4 )
                printf "offbits: %'d B\n" "$(u8x4_string_to_u32 "$val")"
                ;;
        esac
    done
}

export -f dump_bitmap_file_header

# shellcheck disable=SC2034
parse_bitmap_info_header() {
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

export -f parse_bitmap_info_header

dump_bitmap_info_header() {
    local -n _data=$1
    local sizes=(4 4 4 2 2 4 4 4 4 4 4)
    local offsets=()
    local item_count=${#sizes[@]}

    calc_offsets sizes offsets

    for ((i=0; i < "$item_count"; i++)) do
        local idx="${offsets[$i]}"
        local len="${sizes[$i]}"
        local val="${_data[*]:$idx:$len}"

        case "$i" in
            0 )
                printf "size: %'d B\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            1 )
                printf "width: %'d px\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            2 )
                printf "height: %'d px\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            3 )
                printf "planes: %d\n" "$(u8x2_string_to_u32 "$val")"
                ;;
            4 )
                printf "bitcount: %d\n" "$(u8x2_string_to_u32 "$val")"
                ;;
            5 )
                printf "compression: %d\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            6 )
                printf "sizeimage: %'d B\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            7 )
                printf "x px/m: %'d\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            8 )
                printf "y px/m: %'d\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            9 )
                printf "clrused: %'d\n" "$(u8x4_string_to_u32 "$val")"
                ;;
            10 )
                printf "cirimportant: %'d\n" "$(u8x4_string_to_u32 "$val")"
                ;;
        esac
    done
}

export -f dump_bitmap_info_header
