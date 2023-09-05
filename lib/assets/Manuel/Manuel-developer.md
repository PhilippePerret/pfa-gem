# PFA — Manuel du développeur

## Difficulté des temps

> Note : pour simplifier, on ne ramène plus les temps à 120 minutes comme c'était le cas avant. On ne tient compte que de la durée réelle du film.

La difficulté des temps pour les nœuds tient au fait que :

* Le nœud possède un temps absolu (défini par le paradigme absolu). Ce temps correspond à la position idéale du nœud dans le paradigme.
* Le nœud possède un temps relatif (défini par rapport au film). Ce temps correspond à la position relative (au zéro) du nœud dans le film analysé. Il correspond à l'horloge réelle qui est affichée à l'écran, qu'on appelle "timecode".
* Le nœud possède un *temps relatif exact*. Ce temps correspond à la position réelle du nœud dans le film analysé, *en faisant abstraction du zéro*.

Exemple : 

La clé de voûte se trouve dans l'absolu presque au milieu du film. Elle se trouve à `60 - 2` en temps rapporté à 120 minutes.

Imaginons un film qui commence réellement au temps `0:00:23`, qui possède une durée de `90 minutes` et qui possède une clé de voûte à `0:40:00` (à l'écran).

Dans ce cas, la position exacte de la clé de voûte sera :

~~~bash
   0:40:00
-  0:00:23
= 0:39:37
~~~

Plusieurs méthode pratiques permettent de gérer ces temps :

~~~ruby
Soit cdv, l'instance \PFA::RelativePFA::Node de la clé de voûte.

cdv.start_at
# => \PFA::NTime du temps du nœud tel qu'il a été instancié avec l'horloge du film.

cdv.start_at.exact
# => \PFA::NTime du temps exact du nœud, en tenant compte du zéro

cdv.start_at.exact.to_horloge
# => \String L'horloge exacte, comme si le film commençait à 0:00:00.

cdv.start_at.to_horloge
# => \String L'horloge à l'écran, avec un début de film qui n'est pas à 0:00:00.

cdv.start_at.on_120
# => \Float la minute sur laquelle sera la clé de voûte si le film faisait 120 minutes
# Noter que cette valeur tient forcément compte de la position du zéro, et prend 
# donc la valeur de la position exacte du nœud.


~~~
