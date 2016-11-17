require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/recyclage'

module Sinatra
  module PegassApp
    module Recyclages
        def self.registered(app)

            app.get '/benevoles/recyclages' do
                begin   
                    recyclage = RecyclagesClass.new(get_connexion['pegass'])
                    recyclages = recyclage.listStructure(params['ul'])
                    status 200
                rescue => exception
                    logger.error exception
                    status 500
                end
                
                "#{recyclages.to_json}"
            end

            app.get '/benevoles/recyclages/:competence/:competencecode' do
                begin
                    recyclage = RecyclagesClass.new(get_connexion['pegass'])
                    recyclages = recyclage.listStructureCompetence(params['competence'], params['competencecode'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    logger.error exception
                    status 500
                end
                
                "#{recyclages.to_json}"
            end

            app.get '/benevoles/recyclagesdd/:competence/:competencecode' do
                begin
                    recyclage = RecyclagesClass.new(get_connexion['pegass'])
                    recyclages = recyclage.listStructureCompetenceDD(params['competence'], params['competencecode'], params['dd'], params['page'])
                    status 200
                rescue => exception
                    logger.error exception
                    status 500
                end
                
                "#{recyclages.to_json}"
            end

        end
    end
  end 
end
