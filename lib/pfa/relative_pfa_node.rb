module PFA
class RelativePFA
class Node

  attr_reader :pfa, :key

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
    -draw "rectangle #{left_px},#{top_px} #{right_px},#{box_bottom}"
    CMD
  end

  # La marque pour une séquence (un crochet allongé)
  def svg_lines_for_sequence
    <<~CMD
    -strokewidth #{SVGBuilder::BORDERS[:seq]}
    -stroke #{SVGBuilder::COLORS[:seq]}
    -fill white
    -draw "polyline #{left_px+4},#{top+demiheight} #{left_px+4},#{bottom} #{right_px-4},#{bottom} #{right_px-4},#{top+demiheight}"
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

  # --- MÉTHODES TEMPORELLES ---

  # -- Temps relatifs --

  # [PFA::NTime] Temps (relatif) de début du nœud
  # @note : défini à l'instantiation
  def start_at
    @start_at
  end

  # [PFA::NTime] Temps (relatif) de fin du noeud
  def end_at
    @end_at ||= start_at + duration # attention : 2 NTime
  end

  # \PFA::NTime Durée 
  # Soit elle a été explicitement définie en renseignant le noeud, 
  # soit on lui donne la valeur de la durée absolue
  def duration
    @duration ||= abs_duration
  end

  # [String] Horloge du temps (relatif) de départ
  def horloge
    @horloge ||= start_at.exact.to_horloge
  end

  # -- Temps Absolus --

  # [PFA::NTime] Temps absolu (idéal) de départ
  def abs_start
    @abs_start ||= calc_with_fraction_of_duree(abs_data[:abs_start])
  end

  def abs_end
    @abs_end ||= abs_start + abs_duration
  end

  def abs_duration
    @abs_duration ||= calc_with_fraction_of_duree(abs_data[:abs_duration])
  end

  # --- MÉTHODES DE DIMENSIONNEMENT ---

  # -- Dimensions Absolues --

  def abs_left
    @abs_left ||= abs_start.to_px(pfa)
  end

  def abs_width
    @abs_width ||= abs_duration.to_px(pfa)
  end

  def abs_right
    @abs_right ||= abs_left + abs_width
  end

  def abs_top
    @abs_top ||= AnyBuilder::ABS_TOPS[type]
  end

  # -- Dimensions Relatives --

  def left
    @left ||= start_at.to_px(pfa)
  end

  def width
    @width ||= duration.to_px(pfa)
  end

  def right
    @right ||= left + width
  end

  def top
    @top ||= AnyBuilder::TOPS[type]
  end

  # Hauteur de la boite pour écrire le texte
  def height
    @height ||= AnyBuilder::HEIGHTS[type]
  end


  # --- Predicate Methods ---

  # @return [Bool] true si le nœud courant est après 
  # le nœud [RelativePFA::Node] +node+
  # 
  def after?(node)
    return start_at > node.start_at
  end



  # --- Absolute Data ---

  # \Hash Données absolues du nœud
  def abs_data
    @abs_data ||= AbsolutePFA.data[:nodes][key]
  end
  
  def mark
    abs_data[:hname]
  end

  def type
    abs_data[:type].to_sym
  end

  # --- Calculated Values (dimensions) ---


  def svg_surface
    @svg_surface ||= "#{width}x#{height}"
  end

  # -- Des valeurs qui peuvent servir… --
  def demiheight      ; @demiheight   ||= height / 2                end
  def demiwidth       ; @demiwidth    ||= width  / 2                end
  def abs_demiwidth   ; @absdemiwidth ||= abs_width  / 2            end
  def hcenter         ; @hcenter      ||= left  + demiwidth         end
  def abs_hcenter     ; @abshcenter   ||= abs_left + abs_demiwidth  end
  def vcenter         ; @vcenter      ||= top   + demiheight        end
  def bottom          ; @bottom       ||= top + height              end
  def abs_bottom      ; @abs_bottom   ||= abs_top + height          end
  # Le bas ultime du paradigme ?
  def box_bottom      ; @box_bottom   ||= top + 13 * SVGBuilder::LINE_HEIGHT end


  private

  
  # Méthode qui parse la valeur fournie à l'instantiation pour en
  # tirer les valeurs (@start_at et @duration)  
  def parse_raw_value(value)
    @raw_value = value 
    if value.is_a?(Hash)
      @start_at     = NTime.new(value[:t]||value[:time]||value[:start_at], pfa.zero.to_i)
      @description  = value[:d]||value[:description]
      if value.key?(:duree) || value.key?(:duration)
        # La durée est fournie en secondes, elle doit donc être 
        # ramenée à la valeur sur 120 minutes
        @duration = NTime.new(value[:duree]||value[:duration], 0)
      end
    end
  end

  # @return [PFA::NTime] le temps représenté par une fraction dans
  # les données absolues du Paradigme de Field Augmenté
  # 
  # @param [String] fraction_str
  #   Cette fraction peut avoir les aspects suivants :
  #     1/2
  #     1/2 + 1/48
  #     1/2 - 1/24
  # 
  def calc_with_fraction_of_duree(fraction_str)
    fraction = eval(fraction_str.gsub(/\//,'.0/')) # p.e. 1/24 => 1.0/24
    return PFA::NTime.new(pfa.duration.to_i * fraction, 0)
  end

end #/class Node
end #/class RelativePFA
end #/module PFA
