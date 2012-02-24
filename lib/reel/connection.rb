module Reel
  # A connection to the HTTP server
  class Connection
    attr_reader :request
    
    # Attempt to read this much data
    BUFFER_SIZE = 4096
    
    def initialize(socket)
      @socket = socket
      @parser = RequestParser.new
      @request = nil
    end
    
    def read_request
      return if @request
      
      until @parser.headers
        @parser << @socket.readpartial(BUFFER_SIZE)
      end
      
      @request = Request.new(@parser.http_method, @parser.url, @parser.http_version, @parser.headers)
    end

    def run(app)
      rack_input = Rack::RewindableInput.new(@socket)

      env = {}
      env["REQUEST_METHOD"] = @request.method.to_s.upcase
      env["SERVER_NAME"] = "localhost"
      env["SERVER_PORT"] = "1234"
      env["QUERY_STRING"] = @parser.parser.query_string
      env["rack.version"] = [1,4]
      env["rack.input"] = rack_input
      env["rack.errors"] = $stderr
      env["rack.multithread"] = false
      env["rack.multiprocess"] = false
      env["rack.run_once"] = false
      env["rack.url_scheme"] = "http"
      env["SCRIPT_NAME"] = @request.url
      env["PATH_INFO"] = ""

      if env["SCRIPT_NAME"] == "/"
        env["SCRIPT_NAME"] = ""
        env["PATH_INFO"] = "/"
      end

      status, headers, body = app.call(env)

      respond Reel::Response.new(status, headers, body)
    end
    
    def respond(response, body = nil)
      case response
      when Symbol
        response = Response.new(response, {'Connection' => 'close'}, body)
      when Response
      else raise TypeError, "invalid response: #{response.inspect}"
      end
      
      response.render(@socket)
    rescue Errno::ECONNRESET, Errno::EPIPE
      # The client disconnected early
    ensure
      # FIXME: Keep-Alive support
      @socket.close 
    end
  end
end
