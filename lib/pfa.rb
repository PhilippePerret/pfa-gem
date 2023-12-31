def dbg(str)
  STDOUT.write("\n#{str}\n")
end

module PFA
  LIB_FOLDER = File.join(__dir__)
end

require 'clir'
require 'yaml'
require 'singleton'
require 'log_in_file'
require "pfa/version"
require 'pfa/constants'
require 'pfa/errors_manager'
require 'pfa/temporal_methods'
require 'pfa/node_time'
require 'pfa/relative_pfa'
require 'pfa/absolute_pfa'
require 'pfa/relative_pfa_node'
require 'pfa/relative_pfa_datatime'
require 'pfa/img_builder'
require 'pfa/table_builder'
