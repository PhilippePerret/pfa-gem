#
# PFA Relatif, donc celui étudié
# 
module PFA
  # Pour pouvoir faire :
  #   pfa = PFA.new
  # 
  def self.new(data = nil)
    RelativePFA.new(data)
  end

  # # Pour obtenir le PFA courant (au mépris de toute loi de Démeter…)
  # # 
  # def self.current
  #   @@current
  # end
  # def self.current=(pfa)
  #   @@current = pfa
  # end

class RelativePFA

  # [Hash] Les données du Paradigme de Field Augmenté
  attr_reader :data

  # Instanciation du paradigme
  # 
  # @param input_data [Hash|Nil] Données du paradigme fournies à l'instanciation
  # 
  def initialize(input_data = nil)
    @data = {}
    #
    # -- Traitement de toutes les données fournies --
    # 
    input_data ||= {}
    input_data.each { |k, v| add(k, v) }
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
      # @note
      #   Un noeud doit toujours être défini par une table contenant
      #   :t (ou :time) et :d (ou :description)
      # 
      #   La donnée doit être valide. On en profite aussi pour bien
      #   définir le temps.
      #
      value = value_valid?(value, key)
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

  def node(node_key)
    data[node_key]
  end

  # --- Predicate Methods ---

  # @return true si le paradigme définit le noeud de clé +node_key+
  # 
  def node?(node_key)
    data.key?(node_key.to_sym)
  end

  # Test la pertinence de la définition de la clé +key+ et produit une
  # erreur éclairante en cas de problème.
  #
  def value_valid?(value, key)
    value.is_a?(Hash) || raise(PFAFatalError.new(219, **{key: key, classe: "#{value.class}"}))
    value.merge!(t: value[:time]) if value.key?(:time)
    value.merge!(d: value[:description]) if value.key?(:description)
    value.key?(:t)    || raise(PFAFatalError.new(221, **{noeud: key, classe: "#{value.class}"}))
    value[:t] = PFA.time_from(value[:t])
    value.key?(:d)    || raise(PFAFatalError.new(222, **{noeud: key}))
    return value
  end

  # @return true si les données relative du PFA sont valides
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
    exposition            || raise(PFAFatalError.new(209))
    incident_declencheur  || raise(PFAFatalError.new(202))
    pivot1                || raise(PFAFatalError.new(203))
    developpement_part1   || raise(PFAFatalError.new(204))
    developpement_part2   || raise(PFAFatalError.new(208))
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
      if cle_de_voute
        developpement_part2.after?(cle_de_voute)  || raise_time_error('cle_de_voute', 'developpement_part2')
      end
      pivot2.after?(developpement_part2)        || raise_time_error('developpement_part2', 'pivot2')
    end
    denouement.after?(pivot2)         || raise_time_error('pivot2','denouement')
    climax.after?(denouement)         || raise_time_error('denouement','climax')
    data[:end_time].time > climax.start_at || raise_time_error('end_time','climax', end_time, climax)
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
  def duree
    @duree ||= PFA::NTime.new(end_time, zero.to_i)
  end
  alias :duration :duree

  # Définitions -raccourcis-
  def zero=(value)      ; add(:zero, value)     end
  def end_time=(value)  ; add(:end_time, value) end


  # --- Helper Methods ---




  # --- Output Methods ---

  def to_html(**params)
    puts "Je dois apprendre à sortir en HTML".orange
  end

  def to_img(**params)
    params.key?(:as) || params.merge!(as: :real_book)
    img_builder.build(**params)
  end

  def img_builder
    @img_builder ||= ImgBuilder.new(self)
  end

end #/ class RelativePFA
end #/ module PFA
