require './pegass.rb'
require 'json'

class Emails

    attr_accessor :pegass
    
    def initialize(username, password)
        @pegass = Pegass.new        
        @pegass.connect(username, password)
    end
    
    def listStructure()
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

        moyenscom = {}

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            moyenscom[benevole['id']] = benevole(benevole['id'])
                        
        end
        return moyenscom.to_json
    end
    
    def benevole(nivol)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        
        benevole_com = {}
        
        moyenscom.each do | com |
            if com['moyenComId']=='MAILDOM'
                benevole_com['email']=com['libelle']                
            end
            if com['moyenComId']=='POR'
                benevole_com['portable']=com['libelle']                
            end
        end
        
        return benevole_com
    end
end