#!/bin/bash

# https://docs.microsoft.com/ja-jp/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader
readonly BITMAPFILEHEADER_SIZE=$((2 + 4 + 2 + 2 + 4))

# https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
readonly BITMAPINFOHEADER_SIZE=$((4 + 4 + 4 + 2 + 2 + 4 + 4 + 4 + 4 + 4 + 4))
