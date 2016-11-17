require_relative './pegass'
require 'json'

class StatsFc

    attr_accessor :pegass
    
    def initialize(pegassConnection)
        @pegass = pegassConnection
    end
    
    def listthisyear(ul, year)
        ret = []
        retassis = []
        nb_session = 0
        listsession = @pegass.callUrl("/crf/rest/seance?debut=#{year}-01-01&fin=#{year}-12-31&libelleLike=Formation+continue&page=0&pageInfo=true&perPage=2147483647&structure=#{ul}")
        temp = @pegass.callUrl("/crf/rest/seance?debut=#{year}-01-01&fin=#{year}-12-31&libelleLike=FC&page=0&pageInfo=true&perPage=2147483647&structure=#{ul}")
        listsession['list'] = listsession['list'] + temp['list']
        temp = @pegass.callUrl("/crf/rest/seance?debut=#{year}-01-01&fin=#{year}-12-31&libelleLike=r%C3%A9visions&page=0&pageInfo=true&perPage=2147483647&structure=#{ul}")
        listsession['list'] = listsession['list'] + temp['list']
        compteur = {}
        compteurassis = {}
        listsession['list'].each do |session|
            begin         
                nb_session = nb_session + 1  
                inscription_activite = @pegass.callUrl("/crf/rest/activite/#{session['activite']['id']}") 
                begin
                    inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{session['id']}/inscription")
                    if(!inscription_sessions.nil?)
                        inscription_sessions.each do |inscription_session|
                            user = @pegass.callUrl("/crf/rest/utilisateur/#{inscription_session['utilisateur']['id']}")
                            if(inscription_session['role'].eql? "FORMATEUR" or inscription_session['role'].eql? "315" or inscription_session['role'].eql? "Formateur de Premier Secours")
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
                            elsif(inscription_session['role'].eql? "PARTICIPANT" or
                                  inscription_session['role'].eql? "PREMIERS SECOURS EN EQUIPE DE NIVEAU 1" or
                                  inscription_session['role'].eql? "PREMIERS SECOURS EN EQUIPE DE NIVEAU 2" or
                                  inscription_session['role'].eql? "166" or
                                  inscription_session['role'].eql? "167")
                                if(!compteurassis[inscription_session['utilisateur']['id']].nil?)
                                    compteurassis[inscription_session['utilisateur']['id']]=compteurassis[inscription_session['utilisateur']['id']]+1                                    
                                    
                                    i=0
                                    retassis.each do |formateur|
                                        if(formateur[:id].eql? inscription_session['utilisateur']['id'])
                                            retassis[i][:nombre]=compteurassis[inscription_session['utilisateur']['id']]
                                            break
                                        end
                                        i=i+1
                                    end
                                else
                                    compteurassis[inscription_session['utilisateur']['id']]=1 
                                    block = {
                                        :id => inscription_session['utilisateur']['id'],
                                        :nombre => compteurassis[inscription_session['utilisateur']['id']],
                                        :prenom => user['prenom'],
                                        :nom => user['nom']
                                    }
                                    retassis.push block
                                end
                            else
                                # logger.info inscription_session
                            end
                        end
                    end
                rescue => detail
                    # logger.error detail
                end
            rescue => detail
                # logger.error detail
            end
        end
        
        stats = {}
        stats['formateurs']=ret
        stats['participants']=retassis
        
        return stats
    end
end