require './pegass.rb'
require 'json'

class StatsFormateur

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end
    
    def listthisyear(ul)
        beginOfYear = Date.parse("#{Date.today.year}-01-01")
        endOfYear = Date.parse("#{Date.today.year}-01-31")
        listsession = @pegass.callUrl("/crf/rest/seance?debut=#{Date.today.year}-01-01&fin=#{Date.today.year}-12-31&libelleLike=PSC1&page=0&pageInfo=true&perPage=1000&structure=#{ul}&typeActivite=-2")
        
        sessions = {}
        listsession['list'].each do |session|
            puts session
            inscription_session = @pegass.callUrl("/crf/rest/seance/#{session['id']}/inscription")
            puts inscription_session
            if(inscription_session['role'].eql? "FORMATEUR")                
                user = @pegass.callUrl("/crf/rest/utilisateur/#{inscription['utilisateur']['id']}")
                puts "Session: #{user['prenom']} #{user['nom']}"
            end
        end
        
        
        return sessions
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
end