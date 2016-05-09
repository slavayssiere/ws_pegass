require './pegass.rb'
require 'json'

pegass = Pegass.new
pegass.connect("*****", "****")
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
# https://pegass.croix-rouge.fr/crf/rest/moyencomutilisateur?utilisateur=00001367457P
