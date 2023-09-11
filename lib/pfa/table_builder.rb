#
# Module qui gère l'écriture du tableau du PFA, décrivant tous les
# éléments du PFA (même ceux qui ne sont pas affichés dans le 
# graphique)
# 
# Tous les éléments affichés sont les éléments printed: true dans les
# données absolues du PFA
# 
module PFA

class RelativePFA
  def print_full_table_in_pdf(pdf, **options)
    table_builder.build(pdf, **options)
  end
  def table_builder
    @table_builder ||= TableBuilder.new(self)
  end

class TableBuilder < AnyBuilder

  # Méthode principale qui reçoit un Prawn::View et écrit dedans la
  # table du PFA en respectant les +options+
  # 
  # @param pdf [Prawn::View] 
  # @param options [Hash]
  #           :rotated Si true, on met la table de travers
  #           :font [Hash] La police à utiliser, contenant :name et :size
  # 
  def build(pdf, **options)

    # Penser à utiliser Prawn4book::PdfBook::NTable.safeize(str) pour
    # escaper les mauvais caractères (sauf si inscription directe dans
    # le livre)
     
    table_width   = pdf.bounds.height # car en travers
    table_height  = pdf.bounds.width  # idem
    quart_column  = table_width / 4
    data_table = {
      width:          table_width,
      column_widths:  [quart_column, quart_column, quart_column, quart_column],
      cell_style: {
        border_width: [0,1,0,1],
        inline_format: true,
        padding: [2, 5],
      }
    }

    # -- Description des noeuds --
    nodes = {expo:nil, dev_part1: nil, dev_part2: nil, denoue: nil}
    {
      exposition:           :expo, 
      developpement_part1:  :dev_part1, 
      developpement_part2:  :dev_part2,
      denouement:           :denoue
    }.each do |key_part, key_nodes|
      nodes[key_nodes] = AbsolutePFA.data[:nodes][key_part][:items].collect do |node_key|
        node_key = node_key.to_sym
        # -- Si le paradigme définit ce noeud, on l'ajoute --
        if pfa.node?(node_key)
          node = pfa.send(node_key)
          "<b>#{node.mark}</b> : #{node.description}"
        end
      end.compact.join(' | ')
    end

    data_lines = [
      # -- Entête de table --
      ["EXPOSITION", "DÉV. PARTIE 1", "DÉV. PARTIE 2", "DÉNOUEMENT"],
      # -- 2e ligne --
      [
        pfa.exposition&.description(true), 
        pfa.developpement_part1&.description(true), 
        pfa.developpement_part2&.description(true), 
        pfa.denouement&.description(true)
      ],
      # -- 3e ligne --
      [nodes[:expo], nodes[:dev_part1], nodes[:dev_part2], nodes[:denoue]]
    ]

    #
    # Une fonte est-elle définie ?
    # 
    options.key?(:font) || options.merge!(font: {name:'Arial', size:8})
    options[:font][:name] ||= 'Arial'
    options[:font][:size] ||= 8

    pdf.update do
      font(options[:font][:name], **{size: options[:font][:size]})
      if options[:rotated]
        #
        # Il faut écrire la table de travers
        # 
        rotate(90, :origin => [bounds.width,bounds.height/2]) do 
          # text "La table complète du PFA"
          table(data_lines, data_table) do |tb|
            tb.row(0).style(borders:[:top, :left, :right], border_width:1, align: :center)
            tb.row(-1).style(borders:[:bottom, :left, :right], border_width:1, padding_bottom: 5)
          end
        end
      else
        #
        # Tableau à l'endroit sur la page
        # 
        # text "La table complète du PFA"
        table(data_lines, data_table)
      end
    end #/pdf.update
  end

end #/class TableBuilder
end #/class RelativePFA
end #/module PFA
