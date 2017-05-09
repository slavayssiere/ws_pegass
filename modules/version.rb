require 'sinatra/base'
require 'net/http'
require 'slack-ruby-client'

module Sinatra
  module PegassApp
    module Version
        def self.registered(app)

            app.get '/' do
             
                Slack.configure do |config|
                    config.token = ENV['SLACK_API_TOKEN']
                    fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
                end

                client = Slack::Web::Client.new
                client.auth_test

                client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)

                result = { 
                    :name => "ws_pegass",
                    :author => "sebastien.lavayssiere@gmail.com"
                }
                
                "#{result.to_json}"
            end

            app.get '/version' do
                # result = { 
                #     :version => "2.0.2" 
                # }
                
                # logger.info "call version"
                # logger.warn "call version warning"
                # logger.error "call version error"

                # "#{result.to_json}"
                content_type :json
                send_file('version.json', :type => "application/json")
            end

            app.get '/health' do  

                uri = URI('https://pegass.croix-rouge.fr/my.policy')
                res = Net::HTTP.get_response(uri)
                
                result = { 
                    :status => "OK",
                    :pegass => res.message, 
                }

                "#{result.to_json}"
            end

        end
    end
  end 
end
