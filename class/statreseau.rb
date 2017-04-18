require_relative './pegass'
require 'json'

class StatsReseau

    attr_accessor :pegass
    
    def initialize(pegassConnection)
        @pegass = pegassConnection
    end
    
    def listthisyear(ul, year)
        ret_pse2 = []
        ret_pse1 = []
        ret_psc = []
        ret_ci = []
        ret_ch = []
        nb_mission = 0
        listsession = @pegass.callUrl("/crf/rest/seance?debut=#{year}-01-01&fin=#{year}-12-31&action=65&page=0&pageInfo=true&perPage=2147483647&structure=#{ul}")
        compteur_pse2 = {}
        compteur_pse1 = {}
        compteur_psc = {}
        compteur_ci = {}
        compteur_ch = {}
        
        test=false
        listsession['list'].each do |session|
            begin               
                inscription_activite = @pegass.callUrl("/crf/rest/activite/#{session['activite']['id']}") 
                begin
                    inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{session['id']}/inscription")
                    if(!inscription_sessions.nil?)
                        if(inscription_activite['statut'].eql?('Complète'))
                            nb_mission = nb_mission + 1
                            inscription_sessions.each do |inscription_session|
                                user = @pegass.callUrl("/crf/rest/utilisateur/#{inscription_session['utilisateur']['id']}")
                                case inscription_session['role']
                                when "167" #PSE2
                                    if(!compteur_pse2[inscription_session['utilisateur']['id']].nil?)
                                        compteur_pse2[inscription_session['utilisateur']['id']]=compteur_pse2[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret_pse2.each do |membre|
                                            if(membre[:id].eql? inscription_session['utilisateur']['id'])
                                                ret_pse2[i][:nombre]=compteur_pse2[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur_pse2[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur_pse2[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }                                 
                                        ret_pse2.push block
                                    end
                                when "166" #PSE1
                                    if(!compteur_pse1[inscription_session['utilisateur']['id']].nil?)
                                        compteur_pse1[inscription_session['utilisateur']['id']]=compteur_pse1[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret_pse1.each do |membre|
                                            if(membre[:id].eql? inscription_session['utilisateur']['id'])
                                                ret_pse1[i][:nombre]=compteur_pse1[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur_pse1[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur_pse1[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }                                 
                                        ret_pse1.push block
                                    end
                                when "10" #CH
                                    if(!compteur_ch[inscription_session['utilisateur']['id']].nil?)
                                        compteur_ch[inscription_session['utilisateur']['id']]=compteur_ch[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret_ch.each do |membre|
                                            if(membre[:id].eql? inscription_session['utilisateur']['id'])
                                                ret_ch[i][:nombre]=compteur_ch[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur_ch[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur_ch[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }                                 
                                        ret_ch.push block                                 
                                    end
                                when "276" #CH
                                    if(!compteur_psc[inscription_session['utilisateur']['id']].nil?)
                                        compteur_psc[inscription_session['utilisateur']['id']]=compteur_psc[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret_psc.each do |membre|
                                            if(membre[:id].eql? inscription_session['utilisateur']['id'])
                                                ret_psc[i][:nombre]=compteur_psc[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur_psc[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur_psc[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }                                 
                                        ret_psc.push block                                 
                                    end
                                when "254", "75", "13", "255", "42", "11" #CI
                                    test = true;
                                    if(!compteur_ci[inscription_session['utilisateur']['id']].nil?)
                                        compteur_ci[inscription_session['utilisateur']['id']]=compteur_ci[inscription_session['utilisateur']['id']]+1   
                                        i=0
                                        ret_ci.each do |membre|
                                            if(membre[:id].eql? inscription_session['utilisateur']['id'])
                                                ret_ci[i][:nombre]=compteur_ci[inscription_session['utilisateur']['id']]
                                                break
                                            end
                                            i=i+1
                                        end
                                    else
                                        compteur_ci[inscription_session['utilisateur']['id']]=1 
                                        block = {
                                            :id => inscription_session['utilisateur']['id'],
                                            :nombre => compteur_ci[inscription_session['utilisateur']['id']],
                                            :prenom => user['prenom'],
                                            :nom => user['nom']
                                        }                                 
                                        ret_ci.push block
                                    end
                                else
                                    # logger.info inscription_session
                                end
                            end
                        end                      
                    else
                        # logger.info "inscription nil"
                    end
                rescue => detail
                    # logger.error detail
                end
            rescue => detail
                # logger.error detail
            end
        end
        
        stats = {}
        stats['ci']=ret_ci
        stats['ch']=ret_ch
        stats['pse2']=ret_pse2
        stats['pse1']=ret_pse1
        stats['nb_mission']=nb_mission
        
        return stats
    end
end