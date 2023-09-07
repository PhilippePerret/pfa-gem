#!/usr/bin/env zsh

# Pour faire des essais avec convert
# - Dans Sublime Text, s'assurer que le Build System (Tools) soit sur SchellScript
# - Activer ce fichier
# - Jouer CMD-B 
# - ouvrir l'image ./test/essai_convert.jpg produite
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
  \( -extent 2000x200 -pointsize 40 -background black -stroke white -fill white -gravity Center label:"Un texte simple" \) -geometry +200+200 -gravity SouthEast \
  \( -size 1000x1000 -extent x1000 -stroke black -background red -fill white -gravity Center label:"pour" \) -geometry +100+600 -gravity SouthWest -composite \
  "./essai_convert.jpg"
