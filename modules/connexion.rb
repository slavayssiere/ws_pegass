require 'sinatra/base'
require_relative '../class/pegass'

module Sinatra
  module PegassApp
    module Connexion
        def self.registered(app)

            app.get '/connect' do
                begin                        
                    pegass = Pegass.new
                    result, boolConnect = pegass.connect(params['username'], params['password'])
                    
                    if boolConnect
                        status 200
                    else
                        status 401
                    end

                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{result.to_json}"
            end

            app.get '/connecttest' do    
                pegass = Pegass.new
                result, boolConnect = pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                
                if boolConnect
                    status 200
                else
                    status 401
                end

                "#{result.to_json}"
            end

        end
    end
  end 
end
