require 'sinatra'
require 'sinatra/config_file' # gem install sinatra-contrib
require './pegass.rb'
require './recyclage.rb'

config_file './config.yml'

get '/' do
  'Hello world!'
end


get '/connect' do
  pegass = Pegass.new
  result = pegass.connect(params['username'], params['password'])
  
  "#{result}"
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
   
   "#{recyclages}"
end

get '/benevoles/com' do
   emails = Emails.new(params['username'], params['password'])
   emails_ret = emails.listStructure
   
   "#{emails_ret}"
end

get '/benevoles/nominations/:nivol' do
   pegass = Pegass.new
   pegass.connect(params['username'], params['password'])
   
   path = "/crf/rest/nominationutilisateur?utilisateur=#{params['nivol']}"
   
   nominations = pegass.callUrl(path)

   "#{nominations}"
end