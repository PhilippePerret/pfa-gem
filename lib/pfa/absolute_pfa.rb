#
# Singleton AbsolutePFA
# ---------------------
# 
module PFA
class AbsolutePFAClass
  include Singleton

  # @return Data absolues du Paradigme de Field Augmenté
  # 
  def data
    @data ||= YAML.load_file(ABSOLUTE_DATA_PATH, **{symbolize_names:true})
  end

end #/ AbsolutePFAClass

AbsolutePFA = AbsolutePFAClass.instance

end #/ module PFA
