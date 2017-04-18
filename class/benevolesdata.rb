require 'json'
require_relative './pegass'


class BenevolesData

    attr_accessor :pegass
    
    def initialize(pegassConnection)
        @pegass = pegassConnection
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
            if(benevole['nivol'])          
                moyenscom['list'].push benevole(benevole['nivol'])
            else
                moyenscom['list'].push benevole(benevole['id'])
            end                                    
        end
        return moyenscom
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
        
        benevole_com['nivol']=nivol
        
        return benevole_com
    end
    
    def getDataList(ul, page)
        
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?page='+page+'&pageInfo=true&perPage=10&structure='+ul)
        
        data = {}
        data['list']=[]

        benevoles['list'].each do | benevole |  
            data['list'].push benevole_data(benevole)                                   
        end
        
        
        data['last_page']=page
        data['pages']=benevoles['pages']
        return data
    end
    
    def benevole_data(benevole)
        ben = pegass.callUrl("/crf/rest/infoutilisateur/#{benevole['id']}")
        
        benevole_data = {}
        
        benevole_data['id']=benevole['id']
        benevole_data['allow_external']=ben['inscriptionsExternes']                
        benevole_data['allow_email']=ben['contactParMail']
        benevole_data['prenom']=benevole['prenom']
        benevole_data['nom']=benevole['nom']
        benevole_data['date_naissance']=ben['dateNaissance']
        benevole_data['mailMoyenComId']=ben['mailMoyenComId']
        
        return benevole_data
    end   
    
    def changeinfo(benevol, nivol)
        # {"id":"00001376977M","allow_external":true,"allow_email":true,"prenom":"Sebastien","nom":"LAVAYSSIERE","date_naissance":"1986-03-06T00:00:00","mailMoyenComId":"00001376977M_MAILDOM_2"}
        
        # { "inscriptionsExternes":false,"contactParMail":true,"mailMoyenComId":"00001376977M_MAILDOM_2"}
        return pegass.putUrl("/crf/rest/infoutilisateur/#{nivol}", benevol)
    end 
end
