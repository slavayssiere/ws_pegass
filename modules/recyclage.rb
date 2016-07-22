require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/recyclage'

module Sinatra
  module PegassApp
    module Recyclages
        def self.registered(app)

            app.get '/benevoles/recyclages' do
                begin   
                    recyclage = RecyclagesClass.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    recyclages = recyclage.listStructure(params['ul'])
                    status 200
                rescue => exception
                    status 401
                end
                
                "#{recyclages.to_json}"
            end

            app.get '/benevoles/recyclages/:competence/:competencecode' do
                begin
                    recyclage = RecyclagesClass.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    recyclages = recyclage.listStructureCompetence(params['competence'], params['competencecode'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    status 401
                end
                
                "#{recyclages.to_json}"
            end

            app.get '/benevoles/recyclagesdd/:competence/:competencecode' do
                begin
                    recyclage = RecyclagesClass.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                    recyclages = recyclage.listStructureCompetenceDD(params['competence'], params['competencecode'], '75', params['page'])
                    status 200
                rescue => exception
                    status 401
                end
                
                "#{recyclages.to_json}"
            end

        end
    end
  end 
end
