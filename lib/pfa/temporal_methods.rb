module PFA

  # Reçoit une valeur temporelle quelconque (mais valide) et retourne
  # le temps \Time correspondant
  # 
  # Les valeurs adminissibles sont \Time, \String (format horloge)
  # ou \Integer (nombre de secondes)
  # 
  def self.time_from(value)
    case value
    when Time     then value
    when String   then PFA.h2t(value)
    when Integer  then Time.at(value)
    else raise PFAFatalError.new(52, **{value:"#{value.inspect}::#{value.class}"})
    end
  end

  # Reçoit une horloge au format \String et retourne un nombre
  # de secondes correspondant.
  # 
  # @param \String horloge L'horloge transmise, sous différents 
  #     formats possible, comme 'H:M:S', 'H+M+S' ou 'H,M,S'
  # 
  def self.h2s(horloge)
    s, m, h = horloge.split(/[+,:]/).reverse.collect {|n| n.to_i}
    return (s||0) + (m||0) * 60 + (h||0) * 3600
  end

  # Reçoit une horloge et retourne le temps correspondant
  def self.h2t(horloge)
    Time.at(h2s(horloge))
  end

  # Reçoit un nombre de secondes \Integer et retourne une horloge
  # au format 'H:MM:SS'
  def self.s2h(secondes)
    secondes.is_a?(Integer) || raise(PFAFatalError.new(51), **{value: "#{secondes.inspect}::#{secondes.class}"})
    h = secondes / 3600
    r = secondes % 3600
    m = r / 60
    s = r % 60
    "#{h}:" + [m,s].collect{|n|n.to_s.rjust(2,'0')}.join(':')
  end

  # Reçoit un temps \Time et retourne une horloge 'H:MM:SS' 
  def self.t2h(time)
    time.is_a?(Time) || raise(PFAFatalError.new(50, **{value: "#{time.inspect}::#{time.class}"}))
    return s2h(time.to_i)
  end

  REG_HORLOGE = /[0-9]{1/.freeze
end#/module PFA
