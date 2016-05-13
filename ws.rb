require 'sinatra'
require 'sinatra/config_file' # gem install sinatra-contrib
require 'sinatra/cross_origin'
require './pegass.rb'
require './recyclage.rb'
require './emails.rb'

config_file './config.yml'

configure do
  puts 'Enable cross_origin'
  enable :cross_origin
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"

  # Needed for AngularJS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  halt HTTP_STATUS_OK
end

get '/' do
  'Hello world!'
end


get '/connect' do
  pegass = Pegass.new
  result, boolConnect = pegass.connect(params['username'], params['password'])
  
  if boolConnect
    status 200
  else
    status 401
  end
  "#{result.to_json}"
end

get '/benevoles' do
   pegass = Pegass.new
   #pegass.connect(settings.username, settings.password)
   pegass.connect(params['username'], params['password'])
   benevoles = pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

   "#{benevoles}"
end

get '/benevoles/recyclages' do
   recyclage = Recyclage.new(params['username'], params['password'])
   recyclages = recyclage.listStructure
   
   "#{recyclages.to_json}"
end

get '/benevoles/com' do
   email = Emails.new(params['username'], params['password'])
   emails_ret = email.listStructure
   
   "#{emails_ret.to_json}"
end

get '/benevoles/com/:competence' do
   emails = Emails.new(params['username'], params['password'])
   emails_ret = emails.listStructureWithCompetence(params['competence'])
   
   "#{emails_ret.to_json}"
end

get '/benevoles/nominations/:nivol' do
   pegass = Pegass.new
   pegass.connect(params['username'], params['password'])
   
   path = "/crf/rest/nominationutilisateur?utilisateur=#{params['nivol']}"
   
   nominations = pegass.callUrl(path)

   "#{nominations}"
end