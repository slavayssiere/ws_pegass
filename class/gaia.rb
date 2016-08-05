require 'net/http'
require 'mechanize'
require 'json'

class Gaia
    
    attr_accessor :url_gaia
    attr_accessor :url_identification
    attr_accessor :agent
    
    attr_accessor :f5
    attr_accessor :last
    attr_accessor :session
    attr_accessor :saml
     
    def initialize()
        @url_identification = 'https://id.authentification.croix-rouge.fr' # 'https://id.authentification.croix-rouge.fr'
        @url_gaia = 'https://gaia.croix-rouge.fr'
        @agent = Mechanize.new 
        @agent.user_agent_alias = 'Linux Firefox'
        @agent.redirect_ok = false
        @agent.cookie_jar.clear!
    end

    def connect(username, password)
        path_root = "/"
        path_policy = '/my.policy'
        url_root = @url_identification + path_root
        url_policy = @url_identification + path_policy
        

        # puts "First call"      
        puts "Go to #{url_policy}"
        policy_page = @agent.get url_policy
        while policy_page.code[/30[12]/]
            puts policy_page.header['location']            
            #gestion error logout
            if policy_page.header['location'].eql? "/my.logout.php3?errorcode=19"
                policy_page = agent.get policy_page.header['location'] 
                puts policy_page.inspect
                policy_page.links.each do |link|
                    puts link.inspect 
                end
                policy_page = @agent.get url_root
                puts policy_page.code
            else
                policy_page = agent.get policy_page.header['location']                        
            end
        end

        puts "end of first call: #{policy_page.uri}"

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"
      
        page = @agent.submit search_form
        while page.code[/30[12]/]
            puts page.header['location']
            page = @agent.get page.header['location']
        end

        puts page.header['location']        
        puts "end of submit: #{policy_page.uri}"


        puts "Go to https://gaia.croix-rouge.fr/crf-benevoles/"
        page_gaia = @agent.get 'https://gaia.croix-rouge.fr/crf-benevoles/'
        puts page_gaia.header['location']
        while page_gaia.code[/30[12]/]
          puts page_gaia.header['location']
          page_gaia = @agent.get page_gaia.header['location']
        end

        puts "Go to https://gaia.croix-rouge.fr/crf-benevoles/saml2/acs"
        page_gaia = @agent.get 'https://gaia.croix-rouge.fr/crf-benevoles/saml2/acs'
        puts page_gaia.header['location']
        while page_gaia.code[/30[12]/]
          puts page_gaia.header['location']
          page_gaia = @agent.get page_gaia.header['location']
        end

        boolConnect = false                  
        result = {}
        last = ""
        session = ""        
        
        @agent.cookie_jar.each do |cookie|
            puts cookie.to_s
            if cookie.to_s.include? 'F5_ST'
                result = callUrl('/crf-benevoles/users/userSession') 
                result['F5_ST']=cookie.to_s.split('=')[1]
                @f5=result['F5_ST']
                boolConnect = true            
            end    
            if cookie.to_s.include? 'LastMRH_Session'  
                @last=cookie.to_s.split('=')[1]            
            end  
            if cookie.to_s.include? 'MRHSession'  
                @session=cookie.to_s.split('=')[1]
            end  
        end

        result['LastMRH_Session']=@last
        result['MRHSession']=@session
        result['state']=boolConnect
        #result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
         
        return result, boolConnect
    end
    
    def f5connect(token, last, session)  
        
        @f5=token
        @last=last
        @session=session
            
        cookie_f5 = Mechanize::Cookie.new("F5_ST", token)
        cookie_f5.domain = "authentification.croix-rouge.fr"
        cookie_f5.path = "/"
        cookie_f5.secure = true
        cookie_f5.origin = @url_identification
        @agent.cookie_jar.add(cookie_f5)      
        
        cookie_last = Mechanize::Cookie.new("LastMRH_Session", last)
        cookie_last.domain = "authentification.croix-rouge.fr"
        cookie_last.path = "/"
        cookie_last.secure = true
        cookie_last.origin = @url_identification
        @agent.cookie_jar.add(cookie_last)
        
        cookie_session = Mechanize::Cookie.new("MRHSession", session)
        cookie_session.domain = "authentification.croix-rouge.fr"
        cookie_session.path = "/"
        cookie_session.secure = true
        cookie_session.origin = @url_identification
        @agent.cookie_jar.add(cookie_session)          
        
        result = {}
        boolConnect = true
        begin
            # /crf/rest/mazonegeo
            # /crf/rest/acl/config
            # /crf/rest/structure/mastructureaffichee
          result = callUrl('/crf-benevoles/users/userSession')
          result['LastMRH_Session']=last
          result['MRHSession']=session
          result['F5_ST']=token
          result['state']=boolConnect
          #result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
        rescue => exception
          boolConnect = false
        end
        
        return result, boolConnect
    end
    
    def displayCookies()
        #puts agent.cookie_jar.inspect
        
        @agent.cookie_jar.each do |cookie|
            puts cookie.inspect
        end
    end
    
    def callUrl(path)
        # puts "Get " + path
        url_path = @url_gaia + path        
        page = @agent.get url_path
        puts page.body
        return JSON.parse(page.body)
    end
    
    def putUrl(path, data)
        url_path = @url_gaia + path             
        page = @agent.put url_path, data.to_json, {'Content-Type' => 'application/json'}
        puts page.inspect
        return page.code
    end
end
