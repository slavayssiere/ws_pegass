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
  'Hello world, pegass ws!'
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
   #pegass.connect(params['username'], params['password'])
   pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   benevoles = pegass.callUrl('/crf/rest/utilisateur?action='+params['ul']+'&page=0&pageInfo=true&perPage=600&structure='+params['ul'])

   "#{benevoles.to_json}"
end

get '/benevoles/recyclages' do
   puts params
   
   recyclage = Recyclage.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   recyclages = recyclage.listStructure(params['ul'])
   
   "#{recyclages.to_json}"
end

get '/benevoles/recyclages/:competence' do
   puts params
   
   recyclage = Recyclage.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   recyclages = recyclage.listStructureCompetence(params['competence'], params['ul'])
   
   "#{recyclages.to_json}"
end

get '/benevoles/com' do
   email = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   emails_ret = email.listStructure(params['ul'])
   
   "#{emails_ret.to_json}"
end

get '/benevoles/com/:competence' do
   emails = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   emails_ret = emails.listStructureWithCompetence(params['competence'], params['ul'])
   
   "#{emails_ret.to_json}"
end

get '/benevoles/com/without/:competence' do
   emails = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   emails_ret = emails.listStructureWithoutCompetence(params['competence'], params['ul'])
   
   "#{emails_ret.to_json}"
end

get '/benevoles/com/without/:nocompetence/with/:competence' do
  begin
   emails = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   emails_ret = emails.listStructureComplexe(params['competence'], params['nocompetence'], params['ul'])    
   status 200
  rescue => exception
   status 401
  end
   
   "#{emails_ret.to_json}"
end

get '/benevoles/nominations/:nivol' do
   pegass = Pegass.new
   pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   
   path = "/crf/rest/nominationutilisateur?utilisateur=#{params['nivol']}"
   
   nominations = pegass.callUrl(path)

   "#{nominations.to_json}"
end