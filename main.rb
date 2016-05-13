require './pegass.rb'
require 'json'
require './emails.rb'

emails = Emails.new('lavayssieres','nvv59Js4')
list = emails.listStructure

result = ""
list['list'].each do |com|
    if com['email']
        result=result+"; "+com['email']
        puts com['email']
    end
end

puts result


pegass = Pegass.new
result = pegass.connect("*****", "****")
if result['state'] != 'false'
    
    puts result
    pegass.displayCookies
    benevoles = pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

    benevoles['list'].each do | benevole |
    # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
    puts benevole
    end


    # list compétences: https://pegass.croix-rouge.fr/crf/rest/competences
    # list moyen com: https://pegass.croix-rouge.fr/crf/rest/moyencom

    # https://pegass.croix-rouge.fr/crf/rest/competenceutilisateur/
    # https://pegass.croix-rouge.fr/crf/rest/nominationutilisateur?utilisateur='nivol'
    # https://pegass.croix-rouge.fr/crf/rest/formationutilisateur?utilisateur='nivol'
    # https://pegass.croix-rouge.fr/crf/rest/moyencomutilisateur?utilisateur='nivol'
else
    puts 'error in login'
end