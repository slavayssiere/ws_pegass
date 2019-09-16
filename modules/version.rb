require 'sinatra/base'
require 'net/http'

module Sinatra
  module PegassApp
    module Version
        def self.registered(app)
            app.get '/version' do
                # result = { 
                #     :version => "2.0.2" 
                # }
                
                # logger.info "call version"
                # logger.warn "call version warning"
                # logger.error "call version error"

                # "#{result.to_json}"
                content_type :json
                send_file('version.json', :type => "application/json")
            end

            app.get '/health' do  

                uri = URI('https://pegass.croix-rouge.fr/my.policy')
                res = Net::HTTP.get_response(uri)
                
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
