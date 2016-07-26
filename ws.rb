require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require './class/pegass'
require './modules/benevoles'
require './modules/competences'
require './modules/connexion'
require './modules/recyclage'
require './modules/stats'
require './modules/version'


class PegassApp < Sinatra::Base

  register Sinatra::CrossOrigin
  register Sinatra::PegassApp::Connexion
  register Sinatra::PegassApp::Benevoles
  register Sinatra::PegassApp::Competences
  register Sinatra::PegassApp::Recyclages
  register Sinatra::PegassApp::Stats
  register Sinatra::PegassApp::Version

  configure do
      enable :cross_origin
  end

  set :allow_origin, :any
  set :bind, '0.0.0.0'   
  
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"
    response.headers['Access-Control-Allow-Methods'] = "HEAD,GET,PUT,DELETE,OPTIONS"

    # Needed for AngularJS
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"

    halt 200
  end
end
