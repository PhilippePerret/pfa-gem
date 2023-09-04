module PFA

  class PFAFatalError < StandardError 
    def initialize(err_num, params = nil)
      err_msg = ERRORS[err_num]
      err_msg = err_msg % params unless params.nil?
      super(err_msg)
    end
  end
  class PFAError < StandardError; end

  ERRORS = YAML.load_file(File.join(ASSETS_LANG_FOLDER,'errors.yaml'))

end #/module PFA
