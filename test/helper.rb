require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'feedzirra-redis'

DataMapper.setup(:default, {:adapter => 'redis'})
FEED_URL = 'http://search.twitter.com/search.atom?q=monkeys'

require 'fakeweb'
FakeWeb.register_uri( :get, FEED_URL,
                      :body => File.read('test/fixtures/monkeys_old.atom') )

class Test::Unit::TestCase
end
