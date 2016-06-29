require './pegass.rb'
require 'json'

class StatsFormateur

    attr_accessor :pegass
    
    def initialize(token, last, session)
        @pegass = Pegass.new        
        result, boolConnect = @pegass.f5connect(token, last, session)
    end
    
    def listthisyear(ul)
        ret = []
        listsession = @pegass.callUrl("/crf/rest/seance?debut=#{Date.today.year}-01-01&fin=#{Date.today.year}-12-31&libelleLike=PSC1&page=0&pageInfo=true&perPage=1000&structure=#{ul}&typeActivite=-2")
        compteur = {}
        listsession['list'].each do |session|
            begin           
                inscription_activite = @pegass.callUrl("/crf/rest/activite/#{session['activite']['id']}")                
                if(inscription_activite['statut'].eql? 'Clos')
                    begin
                        inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{session['id']}/inscription")
                        if(!inscription_sessions.nil?)
                            inscription_sessions.each do |inscription_session|
                                if(inscription_session['role'].eql? "FORMATEUR")
                                    user = @pegass.callUrl("/crf/rest/utilisateur/#{inscription_session['utilisateur']['id']}")
                                    puts "Session: #{user['prenom']} #{user['nom']}"
                                    if(!compteur[inscription_session['utilisateur']['id']].nil?)
                                        compteur[inscription_session['utilisateur']['id']]=compteur[inscription_session['utilisateur']['id']]+1
                                        i=0
                                        ret.each do |formateur|
                                            if(formateur[:id].eql? inscription_session['utilisateur']['id'])
                                                ret[i][:nombre]=compteur[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }   
                                        ret.push block
                                    end                                    
                                end
                            end
                        end
                    rescue => detail
                        puts detail
                    end
                end
            rescue => detail
                puts detail
            end
        end
        
        puts ret
        return ret
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