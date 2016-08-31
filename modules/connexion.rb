require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/gaia'

module Sinatra
  module PegassApp
    module Connexion
        def self.registered(app)

            app.get '/connect' do
                begin                        
                    pegass = Pegass.new
                    gaia = Gaia.new

                    result, boolConnect = pegass.connect(params['username'], params['password'])
                    res_gaia, gaiaConnect = gaia.connect(params['username'], params['password'])
                    result['SAML'] = res_gaia['SAML']
                    result['JSESSIONID'] = res_gaia['JSESSIONID']
                    result['utilisateur']['gaia_id']=res_gaia['utiId']
                     
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
                gaia = Gaia.new

                result, boolConnect = pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                res_gaia, gaiaConnect = gaia.SAMLconnect(params['SAML'], params['JSESSIONID'])
                result['SAML'] = res_gaia['SAML']
                result['JSESSIONID'] = res_gaia['JSESSIONID']
                result['utilisateur']['gaia_id']=res_gaia['utiId']
                
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
