module Reel
  class Request
    attr_accessor :method, :version, :url
    METHODS = [:head, :get, :post, :put, :delete, :trace, :options, :connect, :patch]

    class UnsupportedArgumentError < RuntimeError; end
    
    def initialize(method, url, version = "1.1", headers = {})
      @method = method.to_s.downcase.to_sym
      raise UnsupportedArgumentError, "unknown method: #{method}" unless METHODS.include? @method
      
      @url, @version, @headers = url, version, headers
    end
    
    def [](header)
      @headers[header]
    end
  end
end
