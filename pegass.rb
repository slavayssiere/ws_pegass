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
        
        # puts "First call"        
        policy_page = @agent.get url_root
        
        # puts "Post credential on " + url_policy + " with " + @agent.cookie_jar.inspect
        policy_page = @agent.get url_policy

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"

        page = @agent.submit search_form

        boolConnect = false                  
        result = {}
        last = ""
        session = ""
        
        agent.cookie_jar.each do |site|
            puts site
            if site.to_s.include? 'F5_ST'  
                result = callUrl('/crf/rest/gestiondesdroits') 
                result['F5_ST']=site.to_s.split('=')[1]
                boolConnect = true            
            end    
            if site.to_s.include? 'LastMRH_Session'  
                last=site.to_s.split('=')[1]            
            end  
            if site.to_s.include? 'MRHSession'  
                session=site.to_s.split('=')[1]
            end          
        end        
        
        result['LastMRH_Session']=last
        result['MRHSession']=session
        result['state']=boolConnect
         
        return result, boolConnect
    end
    
    def f5connect(token, last, session)  
            
        cookie_f5 = Mechanize::Cookie.new("F5_ST", token)
        cookie_f5.domain = "pegass.croix-rouge.fr"
        cookie_f5.path = "/"
        cookie_f5.secure = true
        cookie_f5.origin = "https://pegass.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_f5)      
        
        cookie_last = Mechanize::Cookie.new("LastMRH_Session", last)
        cookie_last.domain = "pegass.croix-rouge.fr"
        cookie_last.path = "/"
        cookie_last.secure = true
        cookie_last.origin = "https://pegass.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_last)
        
        cookie_session = Mechanize::Cookie.new("MRHSession", session)
        cookie_session.domain = "pegass.croix-rouge.fr"
        cookie_session.path = "/"
        cookie_session.secure = true
        cookie_session.origin = "https://pegass.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_session)          
        
        result = {}
        boolConnect = true
        begin
          result = callUrl('/crf/rest/gestiondesdroits')
          result['LastMRH_Session']=last
          result['MRHSession']=session
          result['F5_ST']=token
          result['state']=boolConnect
        rescue => exception
          boolConnect = false
        end
        
        return result, boolConnect
    end
    
    def displayCookies()
        #puts agent.cookie_jar.inspect
        
        agent.cookie_jar.each do |site|
            puts site.inspect
        end
    end
    
    def callUrl(path)
        # puts "Get " + path
        url_path = @url + path
        page = @agent.get url_path
        return JSON.parse(page.body)
    end
end