require 'net/http'
require 'mechanize'
require 'json'
require 'redis'
require 'sinatra/logger'

class Gaia

    attr_accessor :url_gaia
    attr_accessor :url_identification
    attr_accessor :agent
    
    attr_accessor :f5
    attr_accessor :last
    attr_accessor :session
    attr_accessor :saml
    attr_accessor :jsessionid
     
    attr_accessor :redis
    attr_accessor :logger

    def initialize(log, redis)
        @url_identification = 'https://id.authentification.croix-rouge.fr' # 'https://id.authentification.croix-rouge.fr'
        @url_gaia = 'https://gaia.croix-rouge.fr'
        @agent = Mechanize.new { |a|
            a.post_connect_hooks << lambda { |_,_,response,_|
                if response.content_type.nil? || response.content_type.empty?
                    response.content_type = 'text/html'
                end
            }
        }

        @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @agent.user_agent_alias = 'Linux Firefox'
        @agent.redirect_ok = false
        @agent.cookie_jar.clear!

        @logger = log
        @redis = redis
    end

    def connect(username, password)
        path_root = "/"
        path_policy = '/my.policy'
        url_root = @url_identification + path_root
        url_policy = @url_identification + path_policy
        

        # # logger.info "First call"      
        # # logger.info "Go to #{url_policy}"
        policy_page = @agent.get url_policy
        while policy_page.code[/30[12]/]         
            #gestion error logout
            if policy_page.header['location'].eql? "/my.logout.php3?errorcode=19"
                policy_page = agent.get policy_page.header['location'] 
                # policy_page.links.each do |link|
                #     # logger.info link.inspect 
                # end
                policy_page = @agent.get url_root
            else
                policy_page = @agent.get policy_page.header['location']                        
            end
        end

        # # logger.info "end of first call: #{policy_page.uri}"

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"
      
        page = @agent.submit search_form
        while page.code[/30[12]/]
            # # logger.info page.header['location']
            page = @agent.get page.header['location']
        end

        # # logger.info "end of submit: #{policy_page.uri}"

        # # logger.info "Go to https://gaia.croix-rouge.fr/crf-benevoles/"
        page_gaia = @agent.get 'https://gaia.croix-rouge.fr/crf-benevoles/'
        while page_gaia.code[/30[12]/]
          # # logger.info page_gaia.header['location']
          page_gaia = @agent.get page_gaia.header['location']
        end

        search_form = page_gaia.forms.first
        page_fin = @agent.submit search_form
  
        # displayCookies()

        boolConnect = false                  
        result = {}
        last = ""
        session = ""        

        @agent.cookie_jar.each do |cookie|  
            if cookie.to_s.include? 'SAML'
                result = callUrl('/crf-benevoles/users/userSession', cache=false) 
                @saml=cookie.to_s.split('=')[1]   
                boolConnect = true                    
            end 
            if cookie.to_s.include? 'JSESSIONID'  
                @jsessionid=cookie.to_s.split('=')[1]            
            end 
        end

        result['SAML']=@saml
        result['JSESSIONID']=@jsessionid
        result['state']=boolConnect
        #result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
         
        return result, boolConnect
    end
    
    def SAMLconnect(saml, jsessionid)          
        @saml=saml
        @jsessionid=jsessionid
            
        cookie_saml = Mechanize::Cookie.new("SAML", saml)
        cookie_saml.domain = "gaia.croix-rouge.fr"
        cookie_saml.path = "/crf-benevoles"
        cookie_saml.secure = true
        cookie_saml.origin = "https://gaia.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_saml)  

        cookie_jsessionid = Mechanize::Cookie.new("JSESSIONID", jsessionid)
        cookie_jsessionid.domain = "gaia.croix-rouge.fr"
        cookie_jsessionid.path = "/crf-benevoles/"
        cookie_jsessionid.origin = "https://gaia.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_jsessionid)  

        cookie_lang = Mechanize::Cookie.new("i18next", "fr-FR")
        cookie_lang.domain = "gaia.croix-rouge.fr"
        cookie_lang.path = "/"
        cookie_lang.origin = "https://gaia.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_lang) 

        result = {}
        boolConnect = true
        begin
            # /crf/rest/mazonegeo
            # /crf/rest/acl/config
            # /crf/rest/structure/mastructureaffichee
          result = callUrl('/crf-benevoles/users/userSession', cache=false)
          result['SAML']=@saml
          result['JSESSIONID']=@jsessionid
          result['state']=boolConnect
          #result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
        rescue => exception
          # logger.error exception
          boolConnect = false
        end
        
        return result, boolConnect
    end
    
    def displayCookies()
        ## logger.info agent.cookie_jar.inspect
        
        @agent.cookie_jar.each do |cookie|
            # logger.info cookie.inspect
        end
    end

    def callUrl(path, cache=true, time_cache=60)
        # # logger.info "Get " + path
        get_cache = true
        if cache 
            if @redis.exists(path)
                page = @redis.get(path)
                logger.info "get path from redis: #{path}"
                page_parse = JSON.parse(page)
                get_cache = false
            end
        end
        
        if get_cache
            url_path = @url_gaia + path 
            page = @agent.get url_path
            page_parse = JSON.parse(page.body)
            if cache 
                @redis.set(path, page.body)
                @redis.expire(path, time_cache)
            end
        end

        return page_parse
    end
    
    def putUrl(path, data)
        url_path = @url_gaia + path             
        page = @agent.put url_path, data.to_json, {'Content-Type' => 'application/json'}
        # logger.info page.inspect
        return page.code
    end

    def postUrl(path, data)
        url_path = @url_gaia + path             
        page = @agent.post url_path, data.to_json, {'Content-Type' => 'application/json'}
        # logger.info page.inspect
        return page.code
    end
end
