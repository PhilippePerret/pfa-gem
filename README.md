# PFA

PFA pour "Paradigme de Field Augmenté". Ce gem permet de le gérer de façon simple.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pfa'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pfa

## Usage

On commence toujours par instancier un nouveau paradigme.

~~~ruby
require 'pfa'

pfa = PFA::new
~~~

> Ou on définit directement toutes les valeurs [cf. ci-dessous](#with-all-data)

Ensuite, on le renseigne en lui ajoutant des nœuds :

~~~ruby
pfa.add :incident_declencheur, {t:"0+12+0", d:"Louis tue Harlan, le violeur de Selma"}
pdf.add :pivot1, {t:"0,23,15", d:"Louise décide de fuir au Mexique."}
# etc.
~~~

Il faut aussi définir le "zéro" absolu du film et son temps de fin.

> Ce "zéro" permettra de rectifier tous les temps quelle que soit la vidéo utilisée. Par exemple, ce zéro peut être le timecode de la toute première image du film, ou le timecode de l'apparition du titre.
> Tous les autres temps seront donnés normalement.

~~~ruby

pfa.zero = "0:00:25"
pfa.end_time = "1:58:56"

~~~

<a name="with-all-data"></a>

### Définition en fournissant toutes les données

On peut aller très vite en définissant tout :

~~~
require 'pfa'

data_paradigme = {
  zero: 35,
  end_time: 2*60+15,
  incident_declencheur: {t:'0+10+25', d:"LUI rencontre ELLE pour la première fois."},
  pivot1: {t:'0:25;56', d:"<description du premier pivot"},
  developpement_part1: {t: 30*60, d:"<description de la première partie du développement>"}
  # etc. avec toutes les données requises (cf. ci-dessous)
  # ...
}

pfa = PFA.new(data_paradigme)
pfa.to_img 
# => produit l'image du paradigme

# Ou
pfa.to_img(**{as: :default})
# => Produit l'image avec d'autres dimension

~~~

> Noter les différentes formes que peut prendre le temps : une horloge normale ("0:23:45"), une horloge avec des "+" (attention : ce n'est pas une addition, c'est juste un signe plus facile à écrire), une horloge avec des virgules ("0,3,15" — plus facile à écrire aussi), un nombre de secondes (3752), et même un temps `Time` (Time.at(152)).

### Données minimales 

Pour pouvoir être construit, un *PFA* doit définir au moins les nœuds suivants. Tous ces nœuds doivent être définis avec la méthode `pfa#add` et les deux arguments requis, la clé symbolique (p.e. `:pivot2`) et une table contenant la clé `t:` (timecode), la clé `d:` (description) et optionnellement la clé `:duree` (nombre de secondes).

~~~bash
:exposition 
:incident_declencheur
:pivot1
:developpement_part1
:developpement_part2
:pivot2
:denouement
:climax
~~~

> Si un de ces nœuds n'est pas défini, ou que les propriétés `zero` et `end_time` ne sont pas définies, la construction produira une erreur.

La liste complète des clés utilisables et définissables de la même manière est :

~~~bash
:exposition
:preambule
:incident_perturbateur
:incident_declencheur
:zone_de_refus
:pivot1
:developpement_part1
:premiere_action
:premier_tiers
:cle_de_voute
:developpement_part2
:premiere_action_dev2
:deuxieme_tiers
:crise
:pivot2
:denouement
:premier_action_denouement
:climax
:desinence
~~~

Une fois les nœuds du paradigme définis, on peut le construire…

* sous forme d'image JPEG :
  
  ~~~ruby
  pfa.to_img
  ~~~

  Par défaut, ce sera une image pour un livre (environ A5) d'analyse de film comme ceux produit par la collection « Leçons du cinéma ».

* sous forme de fichier HTML (non encore implémenté) :

  ~~~ruby
  pfa.to_html
  ~~~

### Options de sortie

Des options de sortie (premier argument de  `#to_img` ou `#to_html`) permettent d'affiner la sortie attendue.

\[À développer]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PhilippePerret/pfa.

