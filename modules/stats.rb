require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/statfc'
require_relative '../class/statformateur'
require_relative '../class/statml'
require_relative '../class/statreseau'
require_relative '../class/statmaraude'

module Sinatra
  module PegassApp
    module Stats
        def self.registered(app)

            app.get '/stats/formations' do
                stats = StatsFormateur.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                sessions = stats.listthisyear(params['ul'], params['year'])
                
                "#{sessions.to_json}"
            end

            app.get '/stats/maraude' do
                stats = StatsMaraude.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                sessions = stats.listthisyear(params['ul'], params['year'])
                
                "#{sessions.to_json}"
            end

            app.get '/stats/fc' do
                stats = StatsFc.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                sessions = stats.listthisyear(params['ul'], params['year'])
                
                "#{sessions.to_json}"
            end

            app.get '/stats/reseau' do
                stats = StatsReseau.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                sessions = stats.listthisyear(params['ul'], params['year'])
                
                "#{sessions.to_json}"
            end

            app.get '/stats/ml' do
                stats = StatsMl.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
                sessions = stats.listthisyear(params['ul'], params['year'])
                
                "#{sessions.to_json}"
            end

        end
    end
  end 
end
