require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/benevolesdata'

module Sinatra
  module PegassApp
    module Benevoles
        def self.registered(app)

            app.get '/benevoles' do
                begin
                    pegass = Pegass.new
                    pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    benevoles = pegass.callUrl('/crf/rest/utilisateur?action='+params['ul']+'&page=0&pageInfo=true&perPage=600&structure='+params['ul'])
                    status 200
                rescue => exception
                    status 500
                end

                "#{benevoles.to_json}"
            end

            app.get '/benevoles/all' do
                begin
                    bens = BenevolesData.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    bens_ret = bens.getDataList(params['ul'], params['page'])
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{bens_ret.to_json}"
            end

            app.get '/benevoles/com' do
                begin
                    bens = BenevolesData.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    bens_ret = bens.listStructure(params['ul'])   
                    status 200
                rescue => exception
                    status 500
                end
                
                "#{bens_ret.to_json}"
            end


            app.get '/benevoles/nominations/:nivol' do
                pegass = Pegass.new
                pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                
                path = "/crf/rest/nominationutilisateur?utilisateur=#{params['nivol']}"
                
                nominations = pegass.callUrl(path)

                "#{nominations.to_json}"
            end

            app.post '/benevoles/emails' do
                begin
                    listNivol = JSON.parse(request.body.read.to_s)
                    bens = BenevolesData.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    bens_ret = bens.getEmailList(listNivol)
                    status 200
                rescue => exception
                    puts exception
                    status 401
                end
                
                "#{bens_ret.to_json}"
            end

            app.put '/benevoles/changeinfo/:nivol' do
                begin
                    benevol = JSON.parse(request.body.read.to_s)
                    emails = BenevolesData.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    status emails.changeinfo(benevol, params['nivol'])
                rescue => exception
                    puts exception
                    status 500
                end
            end

        end
    end
  end 
end
