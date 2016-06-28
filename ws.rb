require 'sinatra'
require 'sinatra/config_file' # gem install sinatra-contrib
require 'sinatra/cross_origin'
require './pegass.rb'
require './recyclage.rb'
require './emails.rb'
require './competences.rb'

config_file './config.yml'

set :bind, '0.0.0.0'

configure do
  puts 'Enable cross_origin'
  enable :cross_origin
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"

  # Needed for AngularJS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

  halt 200
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

get '/connecttest' do    
  pegass = Pegass.new
  result, boolConnect = pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
  
  if boolConnect
    status 200
  else
    status 401
  end
  "#{result.to_json}"
end


get '/benevoles' do
  begin
   pegass = Pegass.new
   pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   benevoles = pegass.callUrl('/crf/rest/utilisateur?action='+params['ul']+'&page=0&pageInfo=true&perPage=600&structure='+params['ul'])
   status 200
  rescue => exception
   status 401
  end

   "#{benevoles.to_json}"
end

get '/benevoles/recyclages' do
  begin   
   recyclage = Recyclage.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   recyclages = recyclage.listStructure(params['ul'])
   status 200
  rescue => exception
   status 401
  end
   
  "#{recyclages.to_json}"
end

get '/benevoles/recyclages/:competence' do
  begin
   recyclage = Recyclage.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   recyclages = recyclage.listStructureCompetence(params['competence'], params['ul'])
   status 200
  rescue => exception
   status 401
  end
   
  "#{recyclages.to_json}"
end

get '/benevoles/recyclagesdd/:competence' do
  begin
   recyclage = Recyclage.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   recyclages = recyclage.listStructureCompetenceDD(params['competence'], '75')
   status 200
  rescue => exception
   status 401
  end
   
  "#{recyclages.to_json}"
end

get '/benevoles/com' do
  begin
   email = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   emails_ret = email.listStructure(params['ul'])   
   status 200
  rescue => exception
   status 401
  end
   
   "#{emails_ret.to_json}"
end

get '/benevoles/competences/:competence/yes' do
  begin
   puts "search competence (yes) #{params['competence']}"
   comp = Competences.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   comp_ret = comp.listStructureWithCompetence(params['competence'], params['ul'])
   status 200
  rescue => exception
   status 401
  end
  
  "#{comp_ret.to_json}"
end

get '/benevoles/competences/:competence/no' do
  begin
    puts "search competence (no) #{params['competence']}"
   comp = Competences.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   comp_ret = comp.listStructureWithoutCompetence(params['competence'], params['ul'])
   status 200
  rescue => exception
   status 401
  end
   
  "#{comp_ret.to_json}"
end

get '/benevoles/competences/:nocompetence/no/:competence/yes' do
  begin
   comp = Competences.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   comp_ret = comp.listStructureComplexe(params['competence'], params['nocompetence'], params['ul'])    
   status 200
  rescue => exception
   status 401
  end
   
  "#{comp_ret.to_json}"
end

get '/benevoles/nominations/:nivol' do
   pegass = Pegass.new
   pegass.f5connect(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
   
   path = "/crf/rest/nominationutilisateur?utilisateur=#{params['nivol']}"
   
   nominations = pegass.callUrl(path)

   "#{nominations.to_json}"
end

post '/benevoles/emails' do
  begin
    listNivol = JSON.parse(request.body.read.to_s)
    emails = Emails.new(params['F5_ST'], params['LastMRH_Session'], params['MRHSession'])
    emails_ret = emails.getEmailList(listNivol)
    status 200
  rescue => exception
    puts exception
    status 401
  end
   
  "#{emails_ret.to_json}"
end