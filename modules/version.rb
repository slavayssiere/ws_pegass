require 'sinatra/base'
require 'net/http'

module Sinatra
  module PegassApp
    module Version
        def self.registered(app)

            app.get '/' do
                result = { 
                    :name => "ws_pegass",
                    :author => "sebastien.lavayssiere@gmail.com"
                }
                
                "#{result.to_json}"
            end

            app.get '/version' do
                result = { 
                    :version => "1.2.0" 
                }
                
                "#{result.to_json}"
            end

            app.get '/health' do  

                uri = URI('https://pegass.croix-rouge.fr/my.policy')
                res = Net::HTTP.get_response(uri)
                puts res.inspect
                
                result = { 
                    :status => "OK",
                    :pegass => res.message, 
                }

                "#{result.to_json}"
            end

        end
    end
  end 
end
