#!/bin/bash

rm -rf splash/
mkdir -p splash/
convert -coalesce splash.gif splash/splash.png

size=100

(
    echo "const unsigned int splash_gif_w = $size;"
    echo "const unsigned int splash_gif_h = $size;"
    echo "const unsigned int splash_gif_frames = $(find splash/ -type f | wc -l);"
    echo "unsigned char splash_gif[] = {"
    for f in $(find splash/ -type f | sort -V); do
        convert $f -resize ${size}x${size} gray:- | xxd -i
        echo ","
    done
    echo "};"
) > splash.c

