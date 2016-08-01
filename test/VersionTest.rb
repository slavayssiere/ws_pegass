require 'test/unit'
require 'rack/test'
require 'json'
require_relative '../ws'

class VersionTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    PegassApp
  end

  def test_slash
    get '/'
    assert last_response.ok?
    bodyparse = JSON.parse(last_response.body)
    assert_equal 'ws_pegass', bodyparse['name'] 
    assert_equal 'sebastien.lavayssiere@gmail.com', bodyparse['author'] 
  end

  def test_version
    get '/version' #, :name => 'Simon'
    assert last_response.body.include?('version')
  end
end