require 'reel'
require 'sinatra/base'
require 'rack/rewindable_input'

addr, port = '127.0.0.1', 1234

class App < Sinatra::Base
  enable :show_exceptions

  get '/' do
    p env
    "hello"
  end

  post '/foo' do
    "what?"
  end
end

app = Rack::Lint.new(App)

puts "*** Starting server on #{addr}:#{port}"
Reel::Server.new(addr, port) do |connection|
  connection.run(app)
end

p Rack::Handler.get("webrick").run(app, :Port => 1235)

sleep
