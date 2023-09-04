#
# PFA Relatif, donc celui étudié
# 
module PFA
class RelativePFA

  # \Hash Les données du Paradigme de Field Augmenté
  attr_reader :data

  def initialize
    @data = {}
  end

  def method_missing(method_name, *args, &block)
    if data.key?(method_name)
      data[method_name]
    elsif AbsolutePFA.data[:nodes].key?(method_name)
      data[method_name]
    else
      raise NoMethodError.new(method_name)
    end
  end

  # Ajout d'un nœud dans le PFA
  # 
  # On utilise pour le faire : pfa.add(key, value). Si c'est un
  # nœud, la valeur contient {t: '<horloge>', d: "description"}
  # La clé :t peut-être remplacée par :time ou :start_at
  # La clé :d peut-être remplacée par :description
  # 
  def add(key, value)
    # puts "-> add(#{key.inspect}, #{value.inspect}::#{value.class})".orange
    key = key.to_sym
    if AbsolutePFA.data[:nodes].key?(key)
      #
      # Ajout d'un nœud
      # 
      data.merge!(key => RelativePFA::Node.new(self, key, value))

    elsif AbsolutePFA.data[:times].key?(key)
      #
      # Ajout d'une valeur temporelle
      # 
      data.merge!(key => DataTime.new(self, key, value))
    else
      raise PFAFatalError.new(100, **{key: ":#{key}"})
    end
  end

  # Définition d'autres valeurs précise (vanilla)
  # -raccourcis-
  def zero=(value); add(:zero, value) end
  def end_time=(value); add(:end_time, value) end

  # @return \Bool true si les données relative du PFA sont valides
  # 
  # Donc principalement qu'elles existent et qu'elles soient 
  # conformes aux attentes.
  # 
  # Les données minimales pour construire le PFA sont :
  #   - le zéro
  #   - le temps de fin (end_time)
  #   - l'incident déclencheur
  #   - le pivot 1
  #   - le début du développement (developpement_part1)
  #   - le pivot 2
  #   - le début du dénouement (denouement)
  #   - le climax
  # 
  def valid?
    zero                  || raise(PFAFatalError.new(200))
    end_time              || raise(PFAFatalError.new(201))
    incident_declencheur  || raise(PFAFatalError.new(202))
    pivot1                || raise(PFAFatalError.new(203))
    developpement_part1   || raise(PFAFatalError.new(204))
    pivot2                || raise(PFAFatalError.new(205))
    denouement            || raise(PFAFatalError.new(206))
    climax                || raise(PFAFatalError.new(207))

    # --- Vérification de la validité des temps ---
    # 
    incident_declencheur.start_at > zero  || raise_time_error('zero','incident_declencheur')
    pivot1.after?(incident_declencheur)   || raise_time_error('incident_declencheur','pivot1')
    developpement_part1.after?(pivot1)    || raise_time_error('pivot1', 'developpement_part1')
    if cle_de_voute
      cle_de_voute.after?(developpement_part1)  || raise_time_error('developpement_part1','cle_de_voute')
    end
    pivot2.after?(pivot1)                     || raise_time_error('pivot1', 'pivot2')
    if developpement_part2
      developpement_part2.after?(cle_de_voute)  || raise_time_error('cle_de_voute', 'developpement_part2')
      pivot2.after?(developpement_part2)        || raise_time_error('developpement_part2', 'pivot2')
    end
    denouement.after?(pivot2)   || raise_time_error('pivot2','denouement')
    climax.after?(denouement)   || raise_time_error('denouement','climax')
    end_time > climax.start_at  || raise_time_error('end_time','climax', end_time, climax)
  end

  def raise_time_error(key_before, key_after)
    h_before = self.send(key_before.to_sym)
    h_after  = self.send(key_after.to_sym)
    h_before  = PFA.t2h(h_before) if h_before.is_a?(Time)
    h_after   = PFA.t2h(h_after)  if h_after.is_a?(Time)
    h_before  = h_before.horloge  if h_before.is_a?(Node)
    h_after   = h_after.horloge   if h_after.is_a?(Node)
    raise PFAFatalError.new(220, **{
      key_before: key_before, h_before: h_before, 
      key_after: key_after, h_after: h_after
    })
  end

  # --- Volatile Data ---

  def zero      ; data[:zero].time      unless data[:zero].nil?      end
  def end_time  ; data[:end_time].time  unless data[:end_time].nil?  end

  # --- Helper Methods ---




  # --- Output Methods ---

  def to_html
    puts "Je dois apprendre à sortir en HTML".orange
  end

  def to_svg
    puts "Je dois apprendre à sortir en SVG".orange
  end

end #/ class RelativePFA
end #/ module PFA
