require_relative './pegass'
require 'json'

class RolesClass

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end    
    
    def listStructureWithRole(competence, ul, page)
        benevoles = @pegass.callUrl('/crf/rest/utilisateur?page='+page+'&action='+ul+'&page=0&pageInfo=true&perPage=10&structure='+ul+'&role='+competence)

        competence_ul = {}
        competence_ul['list']=[]
        if benevoles['list']
            benevoles['list'].each do | benevole |
                # {"id"=>"nivol", "structure"=>{"id"=>899}, "nom"=>"name", "prenom"=>"first", "actif"=>true}
                comp_bene = {}
                comp_bene['nivol']=benevole['id']
                comp_bene['prenom']=benevole['prenom']
                comp_bene['nom']=benevole['nom']
                competence_ul['list'].push comp_bene            
                            
            end
        end
        
        competence_ul['last_page']=page
        competence_ul['pages']=benevoles['pages']
        return competence_ul
    end            
    
    def getRoles()
       ret = {}
       ret['list']=[]
       comps = @pegass.callUrl("/crf/rest/roles")
       comps.each do |comp|
           if(comp['type'].eql? "NOMI")
               block = {}
               block['id']=comp['id']
               block['libelle']=comp['libelle']
               puts comp['libelle']
               ret['list'].push block
           end
       end
       
       return ret
    end
end