require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/gaia'

module Sinatra
  module PegassApp
    module Connexion
        def self.registered(app)

            app.get '/connect' do
                begin    

                    connexion=get_connexion
                    puts "On connexion: #{connexion.inspect}"

                    result=connexion['res_pegass']
                    result['SAML'] = connexion['res_gaia']['SAML']
                    result['JSESSIONID'] = connexion['res_gaia']['JSESSIONID']
                    result['utilisateur']['gaia_id']=connexion['res_gaia']['utiId']
                     
                    if connexion['pegass_connect']
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
                begin    

                    connexion=get_connexion

                    result=connexion['res_pegass']
                    result['SAML'] = connexion['res_gaia']['SAML']
                    result['JSESSIONID'] = connexion['res_gaia']['JSESSIONID']
                    result['utilisateur']['gaia_id']=connexion['res_gaia']['utiId']
                     
                    if connexion['pegass_connect']
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
        end
    end
  end 
end
