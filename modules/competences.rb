require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/competences'

module Sinatra
  module PegassApp
    module Competences
        def self.registered(app)

            app.get '/competences' do 
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listCompetences()
                    status 200
                rescue => exception
                    logger.error exception
                    status 500
                end

                "#{comp_ret.to_json}"
            end

            app.get '/competences/:type/:competenceid' do 
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listStructureWithCompetenceId(params['competenceid'], params['type'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    logger.error exception
                    status 401
                end

                "#{comp_ret.to_json}"
            end

            app.get '/competences/tc' do 
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listStructureTC(params['ul'], params['page'])
                    status 200
                rescue => exception
                    logger.error exception
                    status 401
                end

                "#{comp_ret.to_json}"
            end

            app.get '/competences/:competence/yes' do
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listStructureWithCompetence(params['competence'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/competences/:type/:competenceid/no' do
                begin
                    # # logger.error "search competence (no) #{params['competence']}"
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listStructureWithoutCompetence(params['competenceid'], params['type'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/benevoles/competences/:nocompetence/no/:competence/yes' do
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'], logger)
                    comp_ret = comp.listStructureComplexe(params['competence'], params['nocompetence'], params['ul'], params['page'])    
                    status 200
                rescue => exception
                    # logger.error exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/competences' do
                comp = CompetencesClass.new(get_connexion['pegass'], logger)
                comp_ret = comp.getCompetences()
                
                "#{comp_ret.to_json}"
            end

        end
    end
  end 
end
