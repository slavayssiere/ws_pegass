require './pegass.rb'
require 'json'
require './emails.rb'
require './recyclage.rb'


pegass = Pegass.new
result, boolConnect = pegass.connect("lavayssieres", "nvv59Js4")

puts result
pegass.displayCookies


#pegass.f5connect(result['F5_ST'], result['LastMRH_Session'], result['MRHSession'])
# test = pegass.callUrl('/crf/rest/gestiondesdroits')

recyclage = Recyclage.new(result['F5_ST'], result['LastMRH_Session'], result['MRHSession'])
recyclage.pegass.displayCookies
recyclages = recyclage.listStructure

puts recyclages 

    # list compétences: https://pegass.croix-rouge.fr/crf/rest/competences
    # list moyen com: https://pegass.croix-rouge.fr/crf/rest/moyencom

    # https://pegass.croix-rouge.fr/crf/rest/competenceutilisateur/
    # https://pegass.croix-rouge.fr/crf/rest/nominationutilisateur?utilisateur='nivol'
    # https://pegass.croix-rouge.fr/crf/rest/formationutilisateur?utilisateur='nivol'
    # https://pegass.croix-rouge.fr/crf/rest/moyencomutilisateur?utilisateur='nivol'
