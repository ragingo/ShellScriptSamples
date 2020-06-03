#!/bin/bash

map_keys() {
    local -n _m=$1
    for k in "${!_m[@]}"; do
        echo "$k"
    done
}

export -f map_keys

map_values() {
    local -n _m=$1
    for v in "${_m[@]}"; do
        echo "$v"
    done
}

export -f map_values

map_entry_count() {
    local -n _m=$1
    echo "${#_m[@]}"
}

export -f map_entry_count

map_contains_key() {
    local -n _m=$1
    local k=$2
    local ret=${_m[$k]:+1}
    echo "${ret:-0}"
}

export -f map_contains_key
