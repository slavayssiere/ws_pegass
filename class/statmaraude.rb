require_relative './pegass'
require 'json'

class StatsMaraude

    attr_accessor :pegass
    
    def initialize(pegassConnection)
        @pegass = pegassConnection
    end
    
    def listthisyear(ul, year)
        ret = []
        retassis = []
        session_incomplete = []
        session_annulee = []
        nb_maraude = 0
        
        listsession = @pegass.callUrl("/crf/rest/seance?debut=#{year}-01-01&fin=#{year}-12-31&libelleLike=Maraude&page=0&pageInfo=true&perPage=2147483647&structure=#{ul}")                                       
        compteur = {}
        compteurassis = {}
        listsession['list'].each do |session|
            begin           
                inscription_activite = @pegass.callUrl("/crf/rest/activite/#{session['activite']['id']}")                
                # puts "#{nb_maraude}: #{inscription_activite['statut']}"
                if(inscription_activite['statut'].eql? 'Complète' or inscription_activite['statut'].eql? 'Incomplète')
                    begin                    
                        nb_maraude = nb_maraude + 1
                        inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{session['id']}/inscription")
                        if(!inscription_sessions.nil?)
                            inscription_sessions.each do |inscription_session|
                                user = @pegass.callUrl("/crf/rest/utilisateur/#{inscription_session['utilisateur']['id']}")
                                if(inscription_session['role'].eql? "8")
                                    if(!compteur[inscription_session['utilisateur']['id']].nil?)
                                        compteur[inscription_session['utilisateur']['id']]=compteur[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret.each do |maraudeur|
                                            if(maraudeur[:id].eql? inscription_session['utilisateur']['id'])
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
                                elsif(inscription_session['role'].eql? "15" or inscription_session['role'].eql? "PARTICIPANT")
                                    if(!compteurassis[inscription_session['utilisateur']['id']].nil?)
                                        compteurassis[inscription_session['utilisateur']['id']]=compteurassis[inscription_session['utilisateur']['id']]+1                                    
                                        
                                        i=0
                                        retassis.each do |maraudeur|
                                            if(maraudeur[:id].eql? inscription_session['utilisateur']['id'])
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
                                end
                            end
                        end
                    rescue => detail
                        puts detail
                    end
                elsif(inscription_activite['statut'].eql? 'Incomplète')
                    block = {}
                    block['date']=inscription_activite['seanceList'][0]['debut']
                    session_incomplete.push block
                elsif(inscription_activite['statut'].eql? 'Annulée')
                    block = {}
                    block['date']=inscription_activite['seanceList'][0]['debut']
                    session_annulee.push block
                else
                    puts "error"
                    puts inscription_activite
                end
            rescue => detail
                puts detail
            end
        end
        
        stats = {}
        stats['chef']=ret
        stats['maraudeur']=retassis
        stats['annulee']=session_annulee
        stats['incomplete']=session_incomplete
        stats['nb_maraude']=nb_maraude
        
        return stats
    end
end