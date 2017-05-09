require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/gaia'
require_relative '../class/benevolesdata'

module Sinatra
  module PegassApp
    module Benevoles
        def self.registered(app)

            app.get '/benevoles' do
                begin
                    connexion=get_connexion
                    benevoles = connexion['pegass'].callUrl('/crf/rest/utilisateur?action='+params['ul']+'&page=0&pageInfo=true&perPage=200&structure='+params['ul'])
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end

                "#{benevoles.to_json}"
            end

            app.get '/benevoles/all' do
                begin
                    bens = BenevolesData.new(get_connexion['pegass'])
                    bens_ret = bens.getDataList(params['ul'], params['page'])
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{bens_ret.to_json}"
            end

            app.get '/benevoles/com' do
                begin
                    bens = BenevolesData.new(get_connexion['pegass'])
                    bens_ret = bens.listStructure(params['ul'])   
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{bens_ret.to_json}"
            end

            app.get '/benevoles/nominations/:nivol' do
                nominations = get_connexion['pegass'].callUrl(path)

                "#{nominations.to_json}"
            end

            app.post '/benevoles/emails' do
                begin
                    listNivol = JSON.parse(request.body.read.to_s)
                    bens = BenevolesData.new(get_connexion['pegass'])
                    bens_ret = bens.getEmailList(listNivol)
                    status 200
                rescue => exception
                    # logger.error exception
                    status 401
                end
                
                "#{bens_ret.to_json}"
            end

            app.put '/benevoles/changeinfo/:nivol' do
                begin
                    benevol = JSON.parse(request.body.read.to_s)
                    emails = BenevolesData.new(get_connexion['pegass'])
                    status emails.changeinfo(benevol, params['nivol'])
                rescue => exception
                    # logger.error exception
                    status 500
                end
            end


            app.get '/benevoles/:nivol' do
                begin
                    bens = BenevolesData.new(get_connexion['pegass'])
                    bens_ret = bens.get_benevole_infos(params['nivol'])
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end

                "#{bens_ret.to_json}"
            end

            app.get '/benevoles/address/:idgaia' do
                begin  
                    bens_ret = get_connexion['gaia'].callUrl("/crf-benevoles/contact/#{params['idgaia']}/mesInfos")   
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{bens_ret.to_json}"
            end

        end
    end
  end 
end
