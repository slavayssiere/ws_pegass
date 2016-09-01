require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/competences'

module Sinatra
  module PegassApp
    module Competences
        def self.registered(app)

            app.get '/benevoles/competences/:competence/yes' do
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'])
                    comp_ret = comp.listStructureWithCompetence(params['competence'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/benevoles/competences/:competence/no' do
                begin
                    # puts "search competence (no) #{params['competence']}"
                    comp = CompetencesClass.new(get_connexion['pegass'])
                    comp_ret = comp.listStructureWithoutCompetence(params['competence'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/benevoles/competences/:nocompetence/no/:competence/yes' do
                begin
                    comp = CompetencesClass.new(get_connexion['pegass'])
                    comp_ret = comp.listStructureComplexe(params['competence'], params['nocompetence'], params['ul'], params['page'])    
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{comp_ret.to_json}"
            end

            app.get '/competences' do
                comp = CompetencesClass.new(get_connexion['pegass'])
                comp_ret = comp.getCompetences()
                
                "#{comp_ret.to_json}"
            end

        end
    end
  end 
end
