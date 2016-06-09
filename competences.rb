require './pegass.rb'
require 'json'

class Competences

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end    
    
    def listStructureWithCompetence(competence, ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        competence_ul = {}
        competence_ul['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret = benevoleWithCompetence(benevole['id'], competence)
                        
            if ret==true
                comp_bene = {}
                comp_bene['nivol']=benevole['id']
                comp_bene['prenom']=benevole['prenom']
                comp_bene['nom']=benevole['nom']
                competence_ul['list'].push comp_bene                
            end
                        
        end
        return competence_ul
    end        
    
    def listStructureWithoutCompetence(competence, ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        competence_ul = {}
        competence_ul['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret = benevoleWithoutCompetence(benevole['id'], competence)
            if ret==true
                comp_bene = {}
                comp_bene['nivol']=benevole['id']
                comp_bene['prenom']=benevole['prenom']
                comp_bene['nom']=benevole['nom']
                competence_ul['list'].push comp_bene               
            end
                        
        end
        return competence_ul
    end
    
    def listStructureComplexe(competence, nocompetence, ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action='+ul+'&page=0&pageInfo=true&perPage=600&structure='+ul)

        competence_ul = {}
        competence_ul['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret = benevoleComplexe(benevole['id'], competence, nocompetence)
            
            # puts "#{benevole['nom']}, #{competence} (yes) #{nocompetence} (no): #{ret}"
            if ret==true
                comp_bene = {}
                comp_bene['nivol']=benevole['id']
                comp_bene['prenom']=benevole['prenom']
                comp_bene['nom']=benevole['nom']
                competence_ul['list'].push comp_bene             
            end
                        
        end
        return competence_ul
    end
    
    def benevoleComplexe(nivol, competence, nocompetence)
        retCompetence = false
        retNoCompetence = true
                         
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        
        formations.each do | formation |
            if formation['formation']['code']==competence
                retCompetence = true
            end
            if formation['formation']['code']==nocompetence
                retNoCompetence = false
            end
        end
        
        ret = retCompetence && retNoCompetence
        
        return ret
    end
    
    def benevoleWithCompetence(nivol, competence)
        ret = false
        endOfYear = Date.parse("#{Date.today.year}-12-31")
        
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
            
        formations.each do | formation |            
            if formation['formation']['code']==competence
                if(formation['dateRecyclage'])
                    dateRecyclage = Date.parse formation['dateRecyclage']
                    avantRecyclage = endOfYear - dateRecyclage
                    
                    puts "#{formation['dateRecyclage']} vs #{endOfYear} = #{avantRecyclage}"
                    
                    if(avantRecyclage <= 0)
                        ret = true
                    end
                else
                    ret = true
                end                
                break
            end
        end        
        
        return ret
    end
    
    def benevoleWithoutCompetence(nivol, competence)
        ret = true
           
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        
        formations.each do | formation |
            if formation['formation']['code']==competence
                ret = false
            end
        end    
        
        return ret
    end
end