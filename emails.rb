require './pegass.rb'
require 'json'

class Emails

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
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
            com_bene['name']=benevole['prenom'] + ' ' + benevole['nom']
            
            if ret==true
                moyenscom['list'].push com_bene                
            end
                        
        end
        return moyenscom
    end        
    
    def listStructureWithoutCompetence(competence)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

        moyenscom = {}
        moyenscom['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret, com_bene = benevoleWithoutCompetence(benevole['id'], competence)
            com_bene['name']=benevole['prenom'] + ' ' + benevole['nom']
            if ret==true
                moyenscom['list'].push com_bene                
            end
                        
        end
        return moyenscom
    end
    
    def listStructureComplexe(competence, nocompetence)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?action=899&page=0&pageInfo=true&perPage=600&structure=899')

        moyenscom = {}
        moyenscom['list']=[]
        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            ret, com_bene = benevoleComplexe(benevole['id'], competence, nocompetence)
            com_bene['name']=benevole['prenom'] + ' ' + benevole['nom']
            if ret==true
                moyenscom['list'].push com_bene                
            end
                        
        end
        return moyenscom
    end
    
    def benevoleComplexe(nivol, competence, nocompetence)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        retCompetence = false
        retNoCompetence = true
        benevole_com = {}
                         
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        
        formations.each do | formation |
            if formation['formation']['code']==competence
                retCompetence = true
            end
            if formation['formation']['code']==nocompetence
                retNoCompetence = false
            end
        end        

        # puts "true, PPNM:#{retNoCompetence}, PSE1:#{retCompetence} #{formations}"
        
        if(retCompetence && retNoCompetence)
            moyenscom.each do | com |
                benevole_com['nivol']=nivol
                if com['moyenComId']=='MAILDOM'
                    benevole_com['email']=com['libelle']                
                end
                if com['moyenComId']=='POR'
                    benevole_com['portable']=com['libelle']                
                end
            end 
        end
        
        ret = retCompetence && retNoCompetence
        
        return ret, benevole_com
    end
    
    def benevoleWithCompetence(nivol, competence)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        ret = false
        benevole_com = {}        
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
        
        if(ret)           
            moyenscom.each do | com |
                benevole_com['nivol']=nivol
                if com['moyenComId']=='MAILDOM'
                    benevole_com['email']=com['libelle']                
                end
                if com['moyenComId']=='POR'
                    benevole_com['portable']=com['libelle']                
                end
            end     
        end      
        
        return ret, benevole_com
    end
    
    def benevoleWithoutCompetence(nivol, competence)
        moyenscom = pegass.callUrl("/crf/rest/moyencomutilisateur?utilisateur=#{nivol}")
        ret = true
        benevole_com = {}        
           
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        
        formations.each do | formation |
            if formation['formation']['code']==competence
                ret = false
            end
        end    
        
        if(ret)
            moyenscom.each do | com |
                benevole_com['nivol']=nivol
                if com['moyenComId']=='MAILDOM'
                    benevole_com['email']=com['libelle']                
                end
                if com['moyenComId']=='POR'
                    benevole_com['portable']=com['libelle']                
                end
            end
        end
        return ret, benevole_com
    end
end