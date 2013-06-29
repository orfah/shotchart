require 'sinatra'
require 'sinatra/base'
require 'sinatra/namespace'
require "sinatra/reloader"

require 'active_record'

connection = YAML.load_file('./config/database.yml')
ActiveRecord::Base.establish_connection(connection['development'])

#require_relative './config.ru'

# require_relative '../model/game-event'
# require_relative '../model/game'
# require_relative '../model/player'
# require_relative '../model/shot'
class Shotchart < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    include Rack::Utils
  end

  after do
    ActiveRecord::Base.connection.close
  end
end

$: << Dir.pwd
Dir.glob('models/*.rb').each {|f| require_relative f.sub!('.rb', '') }
Dir.glob('routes/*.rb').each {|f| require_relative f.sub!('.rb', '') }
Shotchart.run!# Shotchart.new

