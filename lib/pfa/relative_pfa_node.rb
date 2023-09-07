require_relative 'imagemagick_module'

module PFA
class RelativePFA
class Node

  include MagickPFA

  attr_reader :pfa, :key

  attr_reader :description

  def initialize(pfa, key, value = nil)
    @pfa        = pfa
    @key        = key
    parse_raw_value(value)
  end

  def code_image_magick
    pfa.img_builder.code_image_magick
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
  # soit on lui donne la valeur de la durée absolue.
  # Sauf pour les actes, qui possèdent leur propre calcul, étant
  # donné qu'ils dépendent d'autres éléments
  def duration
    @duration ||= begin
      if type == :part
        case key
        when :exposition          then @end_at = pfa.developpement_part1.start_at
        when :developpement_part1 then @end_at = pfa.developpement_part2.start_at
        when :developpement_part2 then @end_at = pfa.denouement.start_at
        when :denouement          then @end_at = PFA::NTime.new(pfa.duration.to_i)
        end
        end_at - start_at 
      else
        abs_duration
      end
    end
  end

  # [String] Horloge du temps (relatif) de départ
  def horloge
    @horloge ||= start_at.to_horloge
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
    @abs_left ||= abs_start.to_px(pfa)#.tap { |n| dbg "abs_left: #{n}".bleu}
  end

  def abs_width
    @abs_width ||= abs_duration.to_px(pfa)
  end

  def abs_right
    @abs_right ||= begin
      if id == 'DE' # denouement
        # Pour que le trait du dénouement soit dans l'image
        abs_left + abs_width - 2
      else
        abs_left + abs_width
      end
    end
  end

  def abs_top
    @abs_top ||= MagickPFA::ABS_TOPS[type]
  end

  def abs_bottom
    @abs_bottom ||= MagickPFA::ABS_BOTTOMS[type]
  end

  def abs_height
    @abs_height ||= MagickPFA::HEIGHTS[type]
  end

  def img_abs_surface
    @img_abs_surface ||= "#{abs_width}x#{abs_height}"
  end

  def abs_font_size
    @abs_font_size ||= MagickPFA::BASE_FONTSIZE * MagickPFA::ABS_FONTSIZES[type]
  end

  # -- Dimensions Relatives --

  def left
    @left ||= start_at.to_px(pfa)
  end

  def width
    @width ||= duration.to_px(pfa)
  end

  def right
    @right ||= begin 
      if id == 'DE' # denouement
        # Pour que le trait du dénouement soit dans l'image
        left + width - 2
      else
        left + width
      end
    end
  end

  def top
    @top ||= MagickPFA::TOPS[type]
  end

  def bottom
    @bottom ||= MagickPFA::BOTTOMS[type]
  end
  
  # Hauteur de la boite pour écrire le texte
  def height
    @height ||= (MagickPFA::HEIGHTS[type]).to_i
  end

  def img_surface
    @img_surface ||= "#{width}x#{height}"
  end

  def font_size
    @font_size ||= MagickPFA::BASE_FONTSIZE * MagickPFA::FONTSIZES[type]
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

  def id
    abs_data[:id]
  end

  # --- Calculated Values (dimensions) ---



  # -- Des valeurs qui peuvent servir… --
  def demiheight      ; @demiheight   ||= height / 2                end
  def demiwidth       ; @demiwidth    ||= width  / 2                end
  def abs_demiwidth   ; @absdemiwidth ||= abs_width  / 2            end
  def hcenter         ; @hcenter      ||= left  + demiwidth         end
  def abs_hcenter     ; @abshcenter   ||= abs_left + abs_demiwidth  end
  def vcenter         ; @vcenter      ||= top   + demiheight        end
  # Le bas ultime du paradigme ?
  def box_bottom      ; @box_bottom   ||= top + 13 * MagickPFA::LINE_HEIGHT end


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
    fraction = eval(fraction_str.to_s.gsub(/\//,'.0/')) # p.e. 1/24 => 1.0/24
    return PFA::NTime.new(pfa.duration.to_i * fraction, 0)
  end

end #/class Node
end #/class RelativePFA
end #/module PFA
