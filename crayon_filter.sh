#!/bin/bash

# Extract 6 frames per second from video
ffmpeg -i $1 -r 6 -s hd720 image%3d.png

# Debug
# ffmpeg -i IMG_1948.MOV -r 6 -t 4 -ss 00:00:07 -s hd720 image%3d.png

# Apply gaussian blur of 6 px to all images
gimp -i -b '(batch-gauss-blur "*.png" 6 6)' -b '(gimp-quit 0)'

# Trace all images to vector images with 16 colors max
for i in $( ls *.png ); do
    autotrace --color-count 16 --output-file $i.svg --output-format svg $i
done

rm ./*.png

# Convert back to png format
for i in $( ls *.svg ); do
    convert $i $i.png
done

rm ./*.svg
    
# Gimp script to add crayon texture to all images
gimp -i -b '(crayon-fx "*.png")' -b '(gimp-quit 0)'

# And make it a video again
ffmpeg -r 6 -i image%03d.png.svg.png -vcodec qtrle -r 24 -pix_fmt rgb24 ${1}-crayon.mov

rm ./*.png
