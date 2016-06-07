require './pegass.rb'
require 'json'

class Recyclage

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end
    
    def listStructure(ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        unite = {}
        unite['list']=[]

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            data_bene={}
            nbRecyclage,recyclage_bene = benevole(benevole['id'])
            
            if(nbRecyclage > 0)
                # puts "#{benevole['nom']}: #{list_formation}"
                data_bene['nivol']=benevole['id']
                data_bene['nom']=benevole['nom']
                data_bene['prenom']=benevole['prenom']
                data_bene['a_recycler']=recyclage_bene
                
                
                unite['list'].push data_bene 
            end 
        end
        return unite
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
    
    def benevoleCompetence(nivol, competence)
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        endOfYear = Date.parse("#{Date.today.year}-12-31")
        
        dateRecyclage = ""
        bARecycler = false
        recyclage_bene={}
        formations.each do | formation |
            if formation['formation']['code'] == competence
                if(formation['dateRecyclage'])
                    dateRecyclage = Date.parse formation['dateRecyclage']
                    avantRecyclage = endOfYear - dateRecyclage
                    if(avantRecyclage >= 0)
                        bARecycler = true
                    end
                end
                break
            end
        end
        
        return bARecycler, dateRecyclage
    end
    
    def listStructureCompetence(competence, ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        unite = {}
        unite['list']=[]

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            data_bene={}
            bARecycler, dateRecyclage = benevoleCompetence(benevole['id'], competence)
            
            if(bARecycler)
                # puts "#{benevole['nom']}: #{list_formation}"
                data_bene['nivol']=benevole['id']
                data_bene['nom']=benevole['nom']
                data_bene['prenom']=benevole['prenom']
                data_bene['date']=dateRecyclage
                
                
                unite['list'].push data_bene 
            end 
        end
        return unite
    end
end