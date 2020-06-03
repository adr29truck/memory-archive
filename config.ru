# frozen_string_literal: true

require 'bundler'

if ENV['RACK_ENV'] == 'production'
  Bundler.require(:default)
else
  Bundler.require(:default, :development)
end

require_relative './bin/server'

Dir['bin/modules/**/*.rb'].each do |file|
  require_relative file
end

# Security settings
use Rack::Protection
use Rack::Protection::StrictTransport
use Rack::Protection::EscapedParams
use Rack::Protection::XSSHeader # For those still using Internet Explorer..
use Rack::Protection::RemoteReferrer
use Rack::Protection::FormToken
use Rack::Protection::AuthenticityToken

port = if ENV['RACK_ENV'] == 'production'
         ENV['PORT']
       else
         9292
       end

Rack::Server.start(
  Port: port,
  Host: '0.0.0.0',
  app: Server,
  SSLEnable: false
)
