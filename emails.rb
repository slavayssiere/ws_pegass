require './pegass.rb'
require 'json'

class Emails

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end
    
    def listStructure(ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        moyenscom = {}
        moyenscom['list']=[]

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            moyenscom['list'].push benevole(benevole['id'])
                                    
        end
        return moyenscom
    end
    
    def getEmailList(list_nivol)        
        moyenscom = {}
        moyenscom['list']=[]

        list_nivol['list'].each do | benevole |            
            moyenscom['list'].push benevole(benevole['nivol'])                                    
        end
        return moyenscom
    end
    
    def benevole(nivol)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        
        benevole_com = {}
        
        moyenscom.each do | com |
            benevole_com['nivol']=nivol
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