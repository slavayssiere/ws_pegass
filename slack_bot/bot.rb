require 'slack-ruby-client'
require 'date'

class PegassBot

    attr_accessor :client
    attr_accessor :pegass
    attr_accessor :gaia
    attr_accessor :si_crf

    def initialize()
        
        puts ENV['SLACK_API_TOKEN']
        
        Slack.configure do |config|
            config.token = ENV['SLACK_API_TOKEN']
            fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
        end

        @client = Slack::RealTime::Client.new

        @client.on :hello do
            puts "Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
        end

        @client.on :close do |_data|
            puts "Client is about to disconnect"
        end

        @client.on :closed do |_data|
            puts "Client has disconnected successfully!"
        end

        @client.on :message do |data|
            discussion_bot(data)
        end


        @si_crf, @pegass, @gaia=connect_pegass

    end

    def start_bot
        @client.start!
    end

    def connect_pegass
        pegass = Pegass.new
        gaia = Gaia.new
        params = {}

        puts "conenction to pegass"
        res_pegass, pegassConnect = pegass.connect(ENV['PEGASS_LOGIN'], ENV['PEGASS_PASSWORD'])

        puts "connection to gaia"
        res_gaia, gaiaConnect = gaia.connect(ENV['PEGASS_LOGIN'], ENV['PEGASS_PASSWORD'])

        params['res_pegass']=res_pegass
        params['res_gaia']=res_gaia
        params['pegass_connect']=pegassConnect
        params['gaia_connect']=gaiaConnect

        return params, pegass, gaia
    end

    def discussion_bot(data)
        case data.text
        when /[pP]egass hi/ then
            @client.message channel: data.channel, text: "Hi <@#{data.user}> connected with pegass: #{si_crf['pegass_connect']}!"
        when /[pP]egass qui est le plus fort ?/ then
            @client.message channel: data.channel, text: "C'est <@#{data.user}>!"
        when /[pP]egass list ul 11/ then
            benevoles = @pegass.callUrl('/crf/rest/utilisateur?page=0&pageInfo=true&perPage=200&structure=899')
            msg = ""
            benevoles['list'].each do |benevole|
                begin
                    msg += "#{benevole['prenom']} #{benevole['nom']}, \n"
                rescue => exception
                    puts exception
                end
            end

            @client.message channel: data.channel, text: msg
        when /[pP]egass [a-zA-Z ]*list[e]* [a-z0-9 ]*(?<match_data>[A-Z0-9]*)/
            reg_sentence = /[pP]egass [a-zA-Z ]*list[e]* [a-z0-9 ]*(?<match_data>[A-Z0-9]*)/
            match_data = reg_sentence.match(data.text)
            
            puts "Search by Bot for #{match_data.captures[0]}"
            comp = CompetencesClass.new(@pegass)
            msg = ""
            nb_loop = 0
            loop do
                comp_ret = comp.listStructureWithCompetence(match_data.captures[0], '899', "#{nb_loop}")
                comp_ret['list'].each do |benevole|
                    msg += "#{benevole['prenom']} #{benevole['nom']}, \n"
                end
                nb_loop = nb_loop + 1
                break if nb_loop >= comp_ret['pages']
            end

             @client.message channel: data.channel, text: msg
        when /[pP]egass quoi de neuf ?/
            date_ajdh=DateTime.now.strftime("%Y-%m-%d")
            list_activite = @pegass.callUrl("/crf/rest/activite?debut=#{date_ajdh}&fin=#{date_ajdh}&structure=899")
            list_activite.each do |activite|
                benevole = @pegass.callUrl("/crf/rest/utilisateur/#{activite['responsable']['id']}")
                
                msg = "*#{activite['libelle']}*, le responsable est #{benevole['prenom']} #{benevole['nom']} sur le poste:\n"
                
                inscription_sessions = @pegass.callUrl("/crf/rest/seance/#{activite['seanceList'][0]['id']}/inscription")
                inscription_sessions.each do |inscrit|
                    benevole_inscrit = @pegass.callUrl("/crf/rest/utilisateur/#{inscrit['utilisateur']['id']}")
                    msg += "- #{benevole_inscrit['prenom']} #{benevole_inscrit['nom']}\n"
                end
                @client.message channel: data.channel, text: msg
            end
            
        when /^pegass/ then
            @client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
        end
    end

end