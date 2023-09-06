# PFA — Manuel pour ImageMagick

Ce document permet de comprendre le code utilisé pour la production du Paradigme de Field Augmenté avec Image magick.



## Description du code

### Introduction

~~~bash
convert -size #{width}x#{height} \
	xc:white \
	-units PixelsPerInch -density 300 \
	-background transparent \
	-set colorspace sRGB

# convert
# 		=> Commande pour produire l’image
# -size widthxheight
#			=> Taille de l'image. 
# 			 Pour un livre d'analyse, c’est 5976 px de large et 3882 px de hauteur
# 			 ATTENTION de bien définir la taille avant le xc:, sinon
# 			 le canevas ferait 1 px / 1 px
# xc:white 
# 		=> Définit le canevas. Sans cette indication, l'image ne peut pas être 
#				 créée
# -units UNITÉ
# 		=> Permet de définir l'unité de la résolution [à confirmer]
#			=> PixelsPerInch = Nombre de pixels par pouce
# -density DENSITÉ
#			=> Définit la résolution
# 		=> 300 points par pouce (pixels par pouce ?)
# -background COULEUR
# 		=> Définit la nature de couleur du fond
# 		=> transparent pour le fond de l'image
# -set colorspace ESPACE_COULEUR
# 		=> Pour définir l'espace de couleur
# 		=> sRGB pour un espace RGB (RVB) avec transparence.
~~~

On dessine le premier **rectangle** pour l’**exposition du paradigme idéal**.

~~~bash
-stroke gray50 -fill white -strokewidth 3 -draw "rectangle 0,258 1494,1806" \

# -stroke COULEUR
#			=> Définission de la couleur du trait/de la police
#			=> gray50 est un gris 50 %
# -fill COULEUR
#			=> Couleur de remplissage de la police
#			=> white, elle sera blanche
# -strokewidth TAILLE
# 		(pas sûr que ce soit nécessaire ici)
#			=> Largeur du trait ou de la police
# 		=> 3 indique une grosseur de 3 pixels. On aura donc un trait
# 			 avec des caractères délimités en noir (stroke) et du
# 			 blanc à l'intérieur
# -draw
# 		=> Pour dessiner quelque chose dans l'image avec les paramètres
# 			 qui viennent d'être définis. Note : on peut aussi dessiner du
# 			 texte avec cette commande, comme on le verra.
#			=> "rectangle 0,258 1494,1806" dessinera un rectangle depuis le
# 			 point 0,258 (left,top) jusqu'au point 1494, 1806 (left, top)
~~~

On pourrait poursuivre en ajoutant les choses à dessiner de la même manière.

~~~bash
-draw "text 4,262 EXPOSITION" \
-draw "rectangle 1494,258 2600,1806" \
-draw "circle ..." \
~~~

Le problème, ci-dessus, se pose particulièrement pour les textes, si on veut les aligner aux boites et aux points (qui représentent des évènements du paradigme). Dans ce cas, il faut utiliser le mode composite :

~~~bash
\( ... définition ... \) -geometry +100-21 -gravity Center -composite

# => \(...\) va définir l'élément à écrire, avec les mêmes paramètres que
#  					 les autres éléments
# 					 Penser à laisser des espaces à l'intérieur.
# => -gravity GRAVITÉ
# 	 Indique l'alignement de la boite par rappart à l'image totale
#		 Center indique que la boite va être alignée au centre verticalement
# 	        et horizontalement. On indique les autres valeurs par North, 
# 					South, East et West. Par exemple NorthWest pour aligner en haut
# 					à gauche.
# => -geometry GEOMÉTRIE
# 		Permet d'ajuster la position de la boite de façon précise par rapport
# 		à la gravité choisie. 
# 		La valeur est un signe et un nombre pour la valeur horizontale et la
#     même chose par rapport à la valeur verticale. Ici, par exemple, on 
# 		ajoutera 100 points horizontalement et on en enlèvera 21 verticalement.
# 		ATTENTION : ces ajouts ne fonctionnement pas de la même manière suivant
# 		la gravité. Par exemple, si la gravité est au sud (South) une valeur 
# 		positive fera REMONTER la boite tandis que si la gravité est au nord
# 		(North) une valeur positive fera DESCENDRE la boite
~~~

On peut trouver entre les `\(...\)` toutes les propriétés qui vont définir l’aspect (`stroke`, `background` etc.).

On prend soin de mettre le label au bout de la définition, pour qu’il profite bien des définitions.

Les définitions à particulière comprendre sont :

~~~bash
\( -size <WxH> -extent <WxH>... label:"Mon label" \) -composite \

# => -size DIMENSION
#		 	Permet de définir la taille du label. Plus la taille sera grande
# 		et plus le label sera affiché gros.
# 		ATTENTION : ça n'est pas la taille de la boite contenant.
# => -extent DIMENSION
# 		Permet de définir la taille véritable de la boite
# => label:"STRING"
# 			Définit le label. Noter qu'il n'y a pas de tiret avant cette
# 			propriété.
~~~

On peut trouver les autres propriétés, dans cette boite :

~~~bash
\( -extent 1000x1000 -gravity SouthEast label:"Label en bas à droite" \) \
	-geometry +100+100
	-gravity Center \
	-composite \

# => -gravity (entre les parenthèses)
#				Définit l'alignement, mais dans la boite de 1000x1000.
# 			Alors que la boite elle-même sera située au centre de l'image,
# 			décalée de 100 points vers le bas et vers la gauche.
~~~



On va écrire le label « Exposition ».

~~~bash
\( -background transparent -stroke gray75 -strokewidth 3 -pointsize 36.0 -size 1494x200 \
  -trim -extent 1494x200 -gravity Center label:"EXPOSITION" \) -gravity NorthWest \
  -geometry +0+420 -composite

~~~



On ajoute le **rectangle** pour la **première partie de développement idéal**.

~~~bash



~~~

