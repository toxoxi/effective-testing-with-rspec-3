require 'sequel'
rack_env = ENV.fetch('RACK_ENV', 'development')
DB = Sequel.sqlite("./db/#{rack_env}.db")
