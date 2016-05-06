require 'net/http'
require 'mechanize'
require 'json'

class Pegass
    
    attr_accessor :url 
    attr_accessor :agent 
    
    def initialize()
        @url = 'https://pegass.croix-rouge.fr'
        @agent = Mechanize.new 
        @agent.user_agent_alias = 'Linux Firefox'
    end

    def connect(username, password)
        path_root = "/"
        path_policy = '/my.policy'
        url_root = @url + path_root
        url_policy = @url + path_policy
        
        puts "First call"        
        policy_page = @agent.get url_root
        
        puts "Post credential on " + url_policy + " with " + @agent.cookie_jar.inspect
        policy_page = @agent.get url_policy

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"

        page = agent.submit search_form

        
    end
    
    def displayCookies()
        puts agent.cookie_jar.inspect
        
        agent.cookie_jar.each do |site|
            puts site
        end
    end
    
    def callUrl(path)
        puts "Get " + path
        url_path = @url + path
        page = @agent.get url_path
        return JSON.parse(page.body)
    end
end