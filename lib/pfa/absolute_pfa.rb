#
# Singleton AbsolutePFA
# ---------------------
# 
# 
# @note
# 
#   Les DATA absolues du paradigme sont définies dans le fichier
#   PFA_ABSOLUTE_DATA.yaml dans le dossier assets/<LANG>
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
