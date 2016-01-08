if defined?(Rails)
  abort('this script must run without Rails')
end

require 'json'
require 'active_record'
require 'active_support/all'
require 'mysql2'
require 'net/ssh/gateway'
require 'redis'
require 'rest-client'
require 'pry'

ActiveRecord::Base.default_timezone = :utc
Time.zone = 'Beijing'

ENV['RUBY_ENV'] ||= 'development'

if ENV['RUBY_ENV'] == 'test'
  $redis = Redis.new(:host => "localhost", :port => 6379, :db => 2)
  $redis.keys.each { |x| $redis.del x }

  db_config = {
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "",
    :port     => 3306
  }
  database = 'ym_test'

  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.drop_database(database)
  ActiveRecord::Base.connection.create_database(database)
  ActiveRecord::Base.establish_connection(db_config.merge(:database => database))
  require File.expand_path('../importer', __FILE__)
  Importer.new.migrate

elsif ENV['RUBY_ENV'] == 'development'
  $redis = Redis.new(:host => "localhost", :port => 6379, :db => 1)
  db_config = {
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "",
    :port     => 3306
  }
  database = 'ym'

  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.create_database(database, charset: 'utf8') rescue nil
  ActiveRecord::Base.establish_connection(db_config.merge(:database => database))

elsif ENV['RUBY_ENV'] == 'production'
  $redis = Redis.new(url: "redis://:sXZFFt71DAkedsttpnOmUQoPA67Z8yHP@weaver:6379/5")

  gateway = Net::SSH::Gateway.new(
    '101.200.231.238', # weaver
    'deployer'
  )

  port = gateway.open('127.0.0.1', 3306)

  db_config = {
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "withwheat",
    :password => "withwheat",
    :port     => port
  }
  database = 'withwheat'

  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.create_database(database, charset: 'utf8') rescue nil
  ActiveRecord::Base.establish_connection(db_config.merge(:database => database))
end

class Product < ActiveRecord::Base; end
class Member < ActiveRecord::Base; end
class MemberFeedback < ActiveRecord::Base; end
class OrderItem < ActiveRecord::Base; end

module Geckoboard; end

class << Geckoboard
  def push id, data
    RestClient.post "https://push.geckoboard.com/v1/send/#{id}", {
      "api_key" => "f29b8d438283af1e366df92b2563f979",
      data: data
    }.to_json, :content_type => :json
  end
end
