#!/usr/bin/env zsh

# Pour faire des essais avec convert
convert -size 4000x6000 xc:white \
  -background transparent \
  -set colorspace sRGB \
  -fill red \
  -units PixelsPerInch \
  -density 300 \
  -stroke black \
  -fill white \
  -strokewidth 3 \
  -draw "rectangle 10,10 2000,2000" \
  -background transparent \
  -fill transparent \
  -draw "rectangle 1000,1000 3000,3000" \
  -draw "text 3600,4900 'Un texte simple'" \
  \( -size 1000x1000 -extent 3600x1000 -stroke black -background red -gravity Center label:"Pour voir" \) -geometry +100+600 -gravity SouthEast -composite \
  "./image_essai.jpg"
