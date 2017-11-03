require 'slack-ruby-client'
require 'date'
require 'logger'
require_relative '../class/pegass'
require_relative '../class/gaia'
require_relative '../class/competences'

class PegassBot

    attr_accessor :client
    attr_accessor :pegass
    attr_accessor :gaia
    attr_accessor :si_crf


    attr_accessor :logger

    def initialize()
        
        @logger = Logger.new('/var/log/pegass-bot.log')
        @logger.info("Token for Slack: #{ENV['SLACK_API_TOKEN']}")

        Slack.configure do |config|
            config.token = ENV['SLACK_API_TOKEN']
            fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
        end

        @client = Slack::RealTime::Client.new

        @client.on :hello do
            @logger.info "Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
        end

        @client.on :close do |_data|
            @logger.info "Client is about to disconnect"
        end

        @client.on :closed do |_data|
            @logger.info "Client has disconnected successfully!"
        end

        @client.on :message do |data|
            begin
                discussion_bot(data)
            rescue => exception
                @logger.error exception
            end
        end

        @si_crf, @pegass, @gaia=connect_pegass

    end

    def start_bot
        @logger.info "Logger start!"
        @client.start!
    end

    def connect_pegass
        pegass = Pegass.new
        gaia = Gaia.new
        params = {}

        @logger.info "connection to pegass"
        res_pegass, pegassConnect = pegass.connect_sso(ENV['PEGASS_LOGIN'], ENV['PEGASS_PASSWORD'])

        @logger.info "connection to gaia"
        res_gaia, gaiaConnect = gaia.connect(ENV['PEGASS_LOGIN'], ENV['PEGASS_PASSWORD'])

        params['res_pegass']=res_pegass
        params['res_gaia']=res_gaia
        params['pegass_connect']=pegassConnect
        params['gaia_connect']=gaiaConnect

        return params, pegass, gaia
    end

    def discussion_bot(data)
        @si_crf, @pegass, @gaia=connect_pegass


        puts data.text

        case data.text
        when /[pP]egass hi/ then
            @client.message channel: data.channel, text: "Bonjour <@#{data.user}>, bonne journée !"
        when /[pP]egass qui est le plus fort ?/ then
            @client.message channel: data.channel, text: "C'est <@#{data.user}>!"
        when /[pP]egass list ul 11/ then
            benevoles = @pegass.callUrl('/crf/rest/utilisateur?page=0&pageInfo=true&perPage=200&structure=899')
            msg = ""
            benevoles['list'].each do |benevole|
                begin
                    msg += "#{benevole['prenom']} #{benevole['nom']}, \n"
                rescue => exception
                    logger.error exception
                end
            end

            @client.message channel: data.channel, text: msg
        when /[pP]egass list[es]* competence[s]*/
            pegass_list_role(data)
        when /[pP]egass list[es]* '(?<match_data>[a-zA-Z0-9 ]*)'/
            pegass_list_competence(data)
        when /[pP]egass quoi de neuf ?/
            pegass_quoi_neuf(data)
        when /[pP]egass [a-zA-Z ]*help[a-zA-Z ]*/
            pegass_help(data)
        when /^[pP]egass/ then
            @logger.info "Pegass, text non compris: #{data.text}"
            @client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
        else
            puts data.text
        end
    end


    def pegass_help(data)
        @logger.info "Pegass help"
        begin
            msg = "Salut <@#{data.user}>, ce bot est une interface à Pegass, tu peux utiliser les commandes:\n"
            msg += " - 'Pegass hi', pour me dire bonjour.\n"
            msg += " - 'Pegass qui est le plus fort ?', pour flatter ton ego.\n"
            msg += " - 'pegass list competences', pour avoir la liste des competences, nomination et formations.\n"
            msg += " - 'Pegass list ul 11', pour avoir la liste des gens de l'ul.\n"
            msg += " - 'Pegass list '-' ', où - est remplacé par une compétence/nomination/formation recherchée (ex:PSE1).\n"
            msg += " - 'Pegass quoi de neuf ?' pour avoir les activités du jour.\n"
            msg += "et enfin 'Pegass help' pour avoir cette commande"
            @client.message channel: data.channel, text: msg
        rescue => exception
            @logger.error exception
        end
    end

    def pegass_list_role(data)
        begin
            competences = @pegass.callUrl('/crf/rest/roles')
            complist = "*Liste compétences:* \n"
            nomilist = "*Liste nominations:* \n"
            formlist = "*Liste formations:* \n"
            competences.each do |competence|
                begin
                    if competence['type'].eql? "COMP"
                        complist += "- #{competence['libelle']}, \n"
                    elsif competence['type'].eql? "NOMI"
                        nomilist += "- #{competence['libelle']}, \n"
                    elsif competence['type'].eql? "FORM"
                        formlist += "- #{competence['libelle']}, \n"
                    end
                rescue => exception
                    @logger.error exception
                end
            end
            @client.message channel: data.channel, text: complist
            @client.message channel: data.channel, text: nomilist
            @client.message channel: data.channel, text: formlist
        rescue => exception
            @logger.error exception
        end
    end

    def pegass_list_competence(data)
        reg_sentence = /[pP]egass [a-zA-Z ]*list[e]* [a-z0-9 ]*'(?<match_data>[a-zA-Z0-9 ]*)'/

        begin
            match_data = reg_sentence.match(data.text)
            @logger.info "Search by Bot for #{match_data.captures[0]}"
            comp = CompetencesClass.new(@pegass)
            cid,type = comp.get_id_formation(match_data.captures[0])
            msg_loop = ""
            nb_loop = 0
            loop do
                comp_ret = comp.listStructureWithCompetenceId(cid,type, '899', "#{nb_loop}")
                comp_ret['list'].each do |benevole|
                    msg_loop += "#{benevole['prenom']} #{benevole['nom']}, \n"
                end
                nb_loop = nb_loop + 1
                break if nb_loop >= comp_ret['pages']
            end

             @client.message channel: data.channel, text: msg_loop
        rescue => exception
            @logger.error exception
        end
    end

    def pegass_quoi_neuf(data)
        @logger.info "Pegass, news"
        begin
            date_ajdh=DateTime.now.strftime("%Y-%m-%d")
            list_activite = @pegass.callUrl("/crf/rest/activite?debut=#{date_ajdh}&fin=#{date_ajdh}&structure=899")
            list_activite.each do |activite|
                benevole = @pegass.callUrl("/crf/rest/utilisateur/#{activite['responsable']['id']}")
                
                msg = "*#{activite['libelle']}*, le responsable est #{benevole['prenom']} #{benevole['nom']} sur le poste:\n"
                
                inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{activite['seanceList'][0]['id']}/inscription")
                inscription_sessions.each do |inscrit|
                    puts inscrit
                    benevole_inscrit = @pegass.callUrl("/crf/rest/utilisateur/#{inscrit['utilisateur']['id']}")
                    msg += "- #{benevole_inscrit['prenom']} #{benevole_inscrit['nom']}, statut: #{inscrit['statut']}\n"
                end
                puts msg
                @client.message channel: data.channel, text: msg
            end
        rescue => exception
            @logger.error exception
        end
    end
end