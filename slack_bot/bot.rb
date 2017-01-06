require 'slack-ruby-client'

class PegassBot

    attr_accessor :client
    attr_accessor :pegass
    attr_accessor :gaia
    attr_accessor :si_crf

    def initialize()
        
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
        when 'pegass hi' then
            @client.message channel: data.channel, text: "Hi <@#{data.user}> connected with pegass: #{si_crf['pegass_connect']}!"
        when 'pegass qui est le plus fort ?' then
            @client.message channel: data.channel, text: "C'est <@#{data.user}>!"
        when 'pegass list ul 11' then
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
        when 'pegass list cip2'
            comp = CompetencesClass.new(@pegass)
            comp_ret = comp.listStructureWithCompetence('CIP2', '899', '1')
            puts comp_ret
            comp_ret['list'].each do |benevole|
                puts benevole['prenom']
                @client.message channel: data.channel, text: "Et #{benevole['prenom']} #{benevole['nom']}!"
            end
                    
        when /^pegass/ then
            @client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
        end
    end

end