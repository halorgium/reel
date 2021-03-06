require 'celluloid/io'
require 'http/parser'

require 'reel/version'

require 'reel/connection'
require 'reel/logger'
require 'reel/request'
require 'reel/request_parser'
require 'reel/response'
require 'reel/server'

# A Reel good HTTP server
module Reel
  # The method given was not understood
  class UnsupportedMethodError < ArgumentError; end
end
