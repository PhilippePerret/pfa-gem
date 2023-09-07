#
# Pour ajouter des méthodes communes à RelativePFA::Node et
# RelativePFA::DataTime
# 
module PFAElementModule

  # @return true si c'est une partie (acte)
  def part?
    return abs_data[:type] == 'part'
  end

  # @return true si c'est un élément imprimable (dans le tableau
  # décrivant le PFA, à ne pas confondre avec le graphique)
  def printable?
    return abs_data[:printed] == true
  end

  # @return true si c'est un élément à dessiner dans le graphique
  # des deux PFA (idéal et réel)
  def drawnable?
    return abs_data[:drawn] == true
  end

  # Sera redéfini pour RelativePFA::Node, mais pas pour
  # 
  def abs_data
    {type: 'data_time', printed: false} 
  end

end #/module PFAElementModule
