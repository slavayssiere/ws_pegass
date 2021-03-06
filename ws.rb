require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'sinatra/logger'
require './class/pegass'
require './class/gaia'
require './modules/benevoles'
require './modules/competences'
require './modules/roles'
require './modules/connexion'
require './modules/recyclage'
require './modules/stats'
require './modules/version'


class PegassApp < Sinatra::Base

  logger filename: "/dev/stdout", level: :trace
  
  register Sinatra::CrossOrigin
  register Sinatra::PegassApp::Connexion
  register Sinatra::PegassApp::Benevoles
  register Sinatra::PegassApp::Competences
  register Sinatra::PegassApp::Roles
  register Sinatra::PegassApp::Recyclages
  register Sinatra::PegassApp::Stats
  register Sinatra::PegassApp::Version

  configure do
      enable :cross_origin
  end

  set :allow_origin, :any
  set :bind, '0.0.0.0'

  helpers do
    def get_connexion
      params = {}
      logger.info "connect to redis... #{ENV['REDIS_HOST']}"
      redis = Redis.new(host: IPSocket.getaddress(ENV['REDIS_HOST']))
      logger.info "connected to redis !"

      pegass = Pegass.new(logger, redis)
      gaia = Gaia.new(logger, redis)

      if(request.env['HTTP_USERNAME'])
        logger.info "test connexion gaia"
        res_gaia, gaiaConnect = gaia.connect(request.env['HTTP_USERNAME'], request.env['HTTP_PASSWORD'])
        logger.info "test connexion pegass"
        res_pegass, pegassConnect = pegass.connect_sso(request.env['HTTP_USERNAME'], request.env['HTTP_PASSWORD'])
        logger.info "connexion successed"
        
        params['gaia']=gaia
        params['pegass']=pegass
        params['res_pegass']=res_pegass
        params['res_gaia']=res_gaia
        params['pegass_connect']=pegassConnect
        params['gaia_connect']=gaiaConnect

      elsif(request.env['HTTP_F5_ST'])
        res_gaia, gaiaConnect = gaia.SAMLconnect(request.env['HTTP_SAML'], request.env['HTTP_JSESSIONID'])
        # res_pegass, pegassConnect = pegass.SAMLconnect(request.env['HTTP_SAML'], request.env['HTTP_JSESSIONID'])
        res_pegass, pegass_connect = pegass.SAMLconnect(request.env['HTTP_F5_ST'], request.env['HTTP_LASTMRH_SESSION'], request.env['HTTP_MRHSESSION'], request.env['HTTP_SHIBSESSION_NAME'], request.env['HTTP_SHIBSESSION_VALUE'])
        params['pegass']=pegass
        params['gaia']=gaia
        params['res_pegass']=res_pegass
        params['res_gaia']=res_gaia
        params['pegass_connect']=pegassConnect
        params['gaia_connect']=gaiaConnect
      end
      params
    end

  end
  
  options "*" do

    # response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"
    response.headers['Access-Control-Allow-Methods'] = "HEAD,GET,PUT,DELETE,POST,OPTIONS"

    response.headers['Access-Control-Allow-Origin'] = "*"
    # Needed for AngularJS
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization, username, password, F5-ST, LastMRH-Session, MRHSession, JSESSIONID, SAML, shibsession_name, shibsession_value"

    halt 200
  end
end
