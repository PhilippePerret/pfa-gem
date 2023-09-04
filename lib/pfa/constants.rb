module PFA

  #
  # La langue, pour le moment fixe
  # 
  LANG = 'fr'

  #
  # Chemin d'accès au dossier ASSETS
  # 
  ASSETS_FOLDER = File.absolute_path(File.join('.','lib','assets'))

  #
  # Chemin d'accès au dossier de LANGUE dans les ASSETS
  # 
  ASSETS_LANG_FOLDER = File.join(ASSETS_FOLDER, LANG)

  #
  # Chemin d'accès au fichier définissant les données absolues du
  # Paradigme de Field Augmenté
  # 
  ABSOLUTE_DATA_PATH = File.join(ASSETS_LANG_FOLDER,'PFA_ABSOLUTE_DATA.yaml')

end #/ module PFA
