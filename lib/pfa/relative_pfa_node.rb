module PFA
class RelativePFA
class Node

  attr_reader :pfa, :key

  attr_reader :start_at
  attr_reader :description

  def initialize(pfa, key, value = nil)
    # puts "\nInstanciation d'un noeud avec #{key.inspect} / #{value.inspect}".orange
    @pfa        = pfa
    @key        = key
    parse_raw_value(value)
  end


  # @return la commande pour construire le fichier SVG
  # 
  def svg_draw_command
    <<~CMD.gsub(/\n/,' ').strip
    #{send("svg_lines_for_#{type}".to_sym)}
    \\(
    -stroke #{SVGBuilder::COLORS[type]}
    -strokewidth #{SVGBuilder::FONTWEIGHTS[type]}
    -pointsize #{SVGBuilder::FONTSIZES[type]}
    -size #{svg_surface}
    label:"#{mark}"
    -background none
    -trim
    -gravity #{SVGBuilder::GRAVITIES[type]}
    -extent #{svg_surface}
    \\)
    -gravity northwest
    -geometry +#{left_px}+#{top}
    -composite
    CMD
  end


  # La marque pour une partie (un rectangle)
  def svg_lines_for_part
    <<~CMD
    -background transparent
    -stroke #{SVGBuilder::DARKERS[:part]}
    -fill white
    -strokewidth #{SVGBuilder::BORDERS[:part]}
    -draw "rectangle #{left_px},#{top} #{right},#{box_bottom}"
    CMD
  end

  # La marque pour une séquence (un crochet allongé)
  def svg_lines_for_sequence
    <<~CMD
    -strokewidth #{SVGBuilder::BORDERS[:seq]}
    -stroke #{SVGBuilder::COLORS[:seq]}
    -fill white
    -draw "polyline #{left+4},#{top+demiheight} #{left+4},#{bottom} #{right-4},#{bottom} #{right-4},#{top+demiheight}"
    #{mark_horloge}
    CMD
  end

  # La marque pour un nœud (un rond/point)
  def svg_lines_for_noeud
    <<~CMD
    -strokewidth #{SVGBuilder::BORDERS[:noeud]}
    -stroke #{SVGBuilder::COLORS[:noeud]}
    -fill white
    -draw "roundrectangle #{left},#{top} #{right},#{bottom} 10,10"
    #{mark_horloge}
    CMD
  end


  def parse_raw_value(value)
    @raw_value = value 
    if value.is_a?(Hash)
      @start_at     = PFA.h2t(value[:t]||value[:time]||value[:start_at])
      @description  = value[:d]||value[:description]
      if value.key?(:duree)
        # La durée est fournie en secondes, elle doit donc être 
        # ramenée à la valeur sur 120 minutes
        @duree = (120 * 60).to_f / (value[:duree]||value[:duration])
      end
    end
  end

  def horloge
    @horloge ||= PFA.t2h(start_at)
  end

  # Le temps de départ ramené à une valeur par rapport à 120 (minutes)
  def start
    @start ||= (120 * 60).to_f / @start_at.to_i
  end

  # Le temps de fin, ramené à une valeur sur 120 (minutes)
  def end
    @end ||= start + duree
  end

  # La durée (ramenée à 120) Soit elle a été explicitement définie en
  # renseignant le noeud, soit on la calcule 
  def duree
    @duree ||= abs_duree
  end
  def abs_duree
    @abs_duree ||= abs_data[:abs_end] - abs_data[:abs_start]
  end


  # @return \Bool true si le nœud courant est après le nœud 
  # \RelativePFA::Node +node+
  # 
  def after?(node)
    return start_at > node.start_at
  end

  # \Hash des données relatives du noeud
  def rel_data
    {
      start_at: @start_at,
      start:    start,
      end:      self.end
    }
  end

  # \Hash Données absolues du nœud
  def abs_data
    @abs_data ||= AbsolutePFA.data[:nodes][key]
  end

  # --- Absolute Data ---
  
  def mark
    abs_data[:hname]
  end

  def type
    abs_data[:type].to_sym
  end

  # --- Calculated Values (dimensions) ---


  def svg_surface
    @svg_surface ||= "#{width_px}x#{height}"
  end

  def height      ; @height       ||= SVGBuilder::HEIGHTS[type]   end
  def demiheight  ; @demiheight   ||= height / 2                  end
  def demiwidth   ; @demiwidth    ||= rel_width / 2               end
  def top         ; @top          ||= SVGBuilder::TOPS[type]      end
  def right       ; @right        ||= rel_left + rel_width        end
  def bottom      ; @bottom       ||= top  + height               end
  def box_bottom  ; @box_bottom   ||= top + 13 * SVGBuilder::LINE_HEIGHT end
  def hcenter     ; @hcenter      ||= left + demiwidth            end
  def vcenter     ; @vcenter      ||= top + demiheight            end

  # === Valeurs calculées ===
  def width_px
    @width_px ||= SVGBuilder.realpx(rel_width)
  end
  def left_px
    @left_px ||= SVGBuilder.realpos(rel_left)
  end
  def rel_width
    @rel_width ||= rel_data[:end] - rel_data[:start]
  end
  def rel_left
    @rel_left ||= rel_data[:start]
  end

end #/class Node
end #/class RelativePFA
end #/module PFA
