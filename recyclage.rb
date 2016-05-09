require './pegass.rb'
require 'json'

class Recyclage

    attr_accessor :pegass
    
    def initialize(username, password)
        @pegass = Pegass.new        
        @pegass.connect(username, password)
    end
    
    def listStructure()
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

        recyclage_struct = {}

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            nbRecyclage,recyclage_bene = benevole(benevole['id'])
            
            if(nbRecyclage > 0)
                # puts "#{benevole['nom']}: #{list_formation}"
                recyclage_struct[benevole['id']]={
                    'nom' => benevole['nom'],
                    'prenom' => benevole['prenom'],
                    'to_recycler' => recyclage_bene
                }
            end 
        end
        return recyclage_struct.to_json
    end
    
    def benevole(nivol)
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        endOfYear = Date.parse("#{Date.today.year}-12-31")
        
        nbRecyclage = 0
        recyclage_bene={}
        formations.each do | formation |
            if(formation['dateRecyclage'])
                dateRecyclage = Date.parse formation['dateRecyclage']
                avantRecyclage = endOfYear - dateRecyclage
                if(avantRecyclage >= 0)
                    nbRecyclage=nbRecyclage+1
                    recyclage_bene[formation['formation']['code']] = dateRecyclage
                end
            end
        end
        
        return nbRecyclage, recyclage_bene
    end
end