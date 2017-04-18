require_relative './pegass'
require 'json'

class RecyclagesClass

    attr_accessor :pegass
    
    def initialize(pegassConnection)
        @pegass = pegassConnection
    end
    
    def listStructure(ul)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?page=0&pageInfo=true&perPage=600&structure='+ul)

        unite = {}
        unite['list']=[]

        benevoles['list'].each do | benevole |
            # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
        
            data_bene={}
            nbRecyclage,recyclage_bene = benevole(benevole['id'])
            
            if(nbRecyclage > 0)
                # # logger.info "#{benevole['nom']}: #{list_formation}"
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
    
    def benevoleCompetence(nivol, competenceid)
        formations = pegass.callUrl("/crf/rest/formationutilisateur?utilisateur=#{nivol}")
        endOfYear = Date.parse("#{Date.today.year}-12-31")
        
        dateRecyclage = ""
        bARecycler = false
        outOfdate = false
        recyclage_bene={}
        formations.each do | formation |
            if formation['formation']['id'] == competenceid
                if(formation['dateRecyclage'])
                    dateRecyclage = Date.parse formation['dateRecyclage']
                    avantRecyclage = endOfYear - dateRecyclage
                    
                    # # logger.info "#{formation['dateRecyclage']} vs #{endOfYear} = #{avantRecyclage}"
                    
                    if(avantRecyclage >= 0)
                        bARecycler = true
                    end
                    
                    if(avantRecyclage > 365)
                        outOfdate = true
                    end
                end
                break
            end
        end
        
        return bARecycler, outOfdate, dateRecyclage
    end
    
    def listStructureCompetence(competenceid, ul, page)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?page='+page+'&formation='+competenceid+'&page=0&pageInfo=true&perPage=10&structure='+ul)
        return parseArecycler(benevoles, competenceid, page)
    end

    def parseArecycler(benevoles, competenceid, page)
        
        unite = {}
        unite['list']=[]
        unite['out']=[]

        begin 
            benevoles['list'].each do | benevole |
                # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
            
                data_bene={}
                bARecycler, outOfdate, dateRecyclage = benevoleCompetence(benevole['id'], competenceid)
                
                if(bARecycler)
                    # # logger.info "#{benevole['nom']}"
                    data_bene['nivol']=benevole['id']
                    data_bene['nom']=benevole['nom']
                    data_bene['prenom']=benevole['prenom']
                    data_bene['date']=dateRecyclage
                    
                    if(outOfdate)
                        unite['out'].push data_bene
                    else
                        unite['list'].push data_bene
                    end 
                end 
            end
        rescue => exception
            puts exception
        end
        
        unite['last_page']=page
        unite['pages']=benevoles['pages']

        puts unite

        return unite
    end
    
    def listStructureCompetenceDD(competenceid, dd, page)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?page='+page+'&pageInfo=true&perPage=11&zoneGeoId='+dd+'&zoneGeoType=departement&formation='+competenceid)
        return parseArecycler(benevoles, competenceid, page)
    end

end
