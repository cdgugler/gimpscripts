#!/bin/bash

# Extract 9 frames per second from video
# ffmpeg -i $1 -r 9 -s hd720 image%3d.png

############ Debug #############
# ffmpeg -i IMG_1949.MOV -r 9 -t 12 -ss 00:00:07 -s hd720 image%3d.png
# or
ffmpeg -i $1 -r 9 -t 12 -ss 00:00:00 -s hd720 image%3d.png
############ Debug #############

echo '***************** Run Gimp Script ***********************'
echo '*********************************************************'
# Gimp script to add crayon texture to all images
gimp -i -b "(crayon-fx-pastel \"*.png\" $2 ${3})" -b '(gimp-quit 0)'


# And make it a video again
ffmpeg -r 9 -i image%03d.png -vcodec qtrle -r 24 -pix_fmt rgb24 ${1}-crayon.mov

# Clean up dir
rm ./*.png
