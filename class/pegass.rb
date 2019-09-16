require 'net/http'
require 'mechanize'
require 'json'
require 'nokogiri'
require 'redis'

class Pegass
    
    attr_accessor :url 
    attr_accessor :agent
    
    attr_accessor :f5
    attr_accessor :last
    attr_accessor :session
    attr_accessor :shibsession

    attr_accessor :redis
    attr_accessor :logger
     
    def initialize(log, redis)
        @url_pegass = 'https://pegass.croix-rouge.fr'
        @url_identification = 'https://id.authentification.croix-rouge.fr' # 'https://id.authentification.croix-rouge.fr'
        
        @url_sso = 'https://pegass.croix-rouge.fr/Shibboleth.sso/SAML2/POST'
        @agent = Mechanize.new
        @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @agent.user_agent_alias = 'Linux Firefox'
        #@agent.log = Logger.new(STDOUT)

        @logger = log
        @redis = redis
    end

    def connect_sso(username, password)
        path_root = "/"
        path_policy = '/my.policy'
        url_root = @url_identification + path_root
        url_policy = @url_identification + path_policy
        

        policy_page = @agent.get @url_pegass
        while policy_page.code[/30[12]/]         
            #gestion error logout
            if policy_page.header['location'].eql? "/my.logout.php3?errorcode=19"
                policy_page = @agent.get policy_page.header['Location'] 
                # policy_page.links.each do |link|
                #     # logger.info link.inspect 
                # end
                policy_page = @agent.get url_root
            else
                puts policy_page.header.inspect
                policy_page = @agent.get policy_page.header['Location']                        
            end
        end
        

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"
      
        page = @agent.submit search_form


        page_redirect_sso = @agent.get page.uri


        saml_response = ""
        relay_state = ""

        begin
            doc = Nokogiri::Slop <<-EOXML
                #{page_redirect_sso.body}
            EOXML
            saml_response = doc.html.body.apm_do_not_touch.form.input.first.attributes['value'].value
            relay_state = doc.html.body.apm_do_not_touch.form.input.first.attributes['value'].value
        rescue => excp
            puts excp.inspect
        end
        
        puts "add headers in agent"
        headers_sso = headers = { 
            "Origin" => "https://id.authentification.croix-rouge.fr",
            "Host" => "pegass.croix-rouge.fr",
            "Referer" => "https://id.authentification.croix-rouge.fr" + page.uri.request_uri(),
            "Accept-Encoding" => "gzip, deflate, br",
            "Accept-Language" =>  "fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4",
            "Upgrade-Insecure-Requests" => "1",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            "Cache-Control" => "max-age=0",
            "Connection" => "keep-alive"
        }
        
        begin
            redirect_sso = @agent.post(uri = "https://pegass.croix-rouge.fr/Shibboleth.sso/SAML2/POST", 
                query = {
                    "SAMLResponse" => saml_response,
                    "RelayState" => relay_state
                }, 
                headers = headers_sso)
        
        rescue
            puts "500 mais j'ai ce que je veux"
        end

        boolConnect = false                  
        result = {}
        last = ""
        session = ""    
        
        begin 
            @agent.cookie_jar.each do |site|
                if site.to_s.include? 'F5_ST'  
                    result = callUrl('/crf/rest/gestiondesdroits', cache=false) 
                    result['F5_ST']=site.to_s.split('=')[1]
                    @f5=result['F5_ST']
                    boolConnect = true            
                end    
                if site.to_s.include? 'LastMRH_Session'  
                    @last=site.to_s.split('=')[1]            
                end  
                if site.to_s.include? 'MRHSession'  
                    @session=site.to_s.split('=')[1]
                end   
                if site.to_s.include? "shibsession" 
                    @shibsession_name=site.to_s.split('=')[0]
                    @shibsession_value=site.to_s.split('=')[1]
                end          
            end  
        rescue => excp
            puts excp.inspect
        end      

        result['LastMRH_Session']=@last
        result['MRHSession']=@session
        result['SHIBSession']= {
            "name" => @shibsession_name,
            "value" => @shibsession_value
        }
        result['state']=boolConnect
        begin
            result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}", cache=false)
            isInTeamFormat, role = getUserInfo(result['utilisateur']['id'])
            result['isInTeamFormat']=isInTeamFormat
            result['role']=role
        rescue => exception
            time1 = Time.new
            puts "#{time1.inspect} #{exception}"
        end 

        timelog = Time.new
        puts "#{timelog.inspect} tentative de connexion de #{username}, #{boolConnect}"

        # puts result.inspect

        return result, boolConnect
    end

    def SAMLconnect(token_f5, last, session, shibsession_name, shibsession_value)          
        cookie_f5 = Mechanize::Cookie.new("F5_ST", token_f5)
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
        
        puts "shibsession_name: #{shibsession_name} & shibsession_value : #{shibsession_value}"
        cookie_session = Mechanize::Cookie.new(shibsession_name, shibsession_value)
        cookie_session.domain = "pegass.croix-rouge.fr"
        cookie_session.path = "/"
        cookie_session.secure = true
        cookie_session.origin = "https://pegass.croix-rouge.fr/my.policy"
        @agent.cookie_jar.add(cookie_session) 

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
          result = callUrl('/crf/rest/gestiondesdroits', cache=false)
          result['SAML']=@saml
          result['JSESSIONID']=@jsessionid
          result['state']=boolConnect
          result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}", cache=false)
          isInTeamFormat, role = getUserInfo(result['utilisateur']['id'])
          result['isInTeamFormat']=isInTeamFormat
          result['role']=role
          #result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
        rescue => exception
          # logger.error exception
          boolConnect = false
        end
        
        return result, boolConnect
    end
    
    def getUserInfo(nivol)
        listTeamFormat = ['00001376977M', '00001727030F', '00001701729E', '00000599352T', '01000000106B', '00001767279E', '01000000105A', '00001245395N']
        isInTeamFormat = false;
        if listTeamFormat.any? { |s| s.include?(nivol) }
            isInTeamFormat = true;
        end

        role = "user"
        if nivol.eql? '00001376977M'
            role = "admin"
        elsif nivol.eql? '00000039302V'
            role = "ddaf" 
        elsif nivol.eql? '00001220657A'
            role = "ddaf" 
        elsif nivol.eql? '00001226177A'
            role = "ddaf"
        else
            nominations = callUrl("/crf/rest/nominationutilisateur?utilisateur=#{nivol}")
            nominations.each do |nomination|
                if nomination.libelleCourt.eql? "DLUS.A.FOR"
                    role = "dlaf"
                elsif nomination.libelleCourt.eql? "DLUS"
                    role = "dlus"
                end
            end
        end
        
        return isInTeamFormat, role
    end
    
    def displayCookies()
        
        @agent.cookie_jar.each do |site|
            puts site.inspect
        end
    end
    
    def callUrl(path, cache=true, time_cache=600)
        # # logger.info "Get " + path
        get_cache = true
        if cache 
            if @redis.exists(path)
                page = @redis.get(path)
                puts "get path from redis: #{path}"
                page_parse = JSON.parse(page)
                get_cache = false
            end
        end
        
        if get_cache
            url_path = @url_pegass + path 
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
        url_path = @url_pegass + path             
        page = @agent.put url_path, data.to_json, {'Content-Type' => 'application/json'}
        return page.code
    end
end
