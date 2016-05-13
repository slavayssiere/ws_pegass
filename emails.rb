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
        moyenscom['list']=[]

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            moyenscom['list'].push benevole(benevole['id'])
                                    
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
    
    def listStructureWithCompetence(competence)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

        moyenscom = {}
        moyenscom['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret, com_bene = benevoleWithCompetence(benevole['id'], competence)
            
            if ret==true
                moyenscom['list'].push com_bene                
            end
                        
        end
        return moyenscom
    end
    
    def benevoleWithCompetence(nivol, competence)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        ret = false
        benevole_com = {}
        
        moyenscom.each do | com |
            benevole_com['nivol']=nivol
            if com['moyenComId']=='MAILDOM'
                benevole_com['email']=com['libelle']                
            end
            if com['moyenComId']=='POR'
                benevole_com['portable']=com['libelle']                
            end
            
            formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
            
            formations.each do | formation |
                if formation['formation']['code']==competence
                    ret = true
                end
            end
        
        end
        
        return ret, benevole_com
    end
end