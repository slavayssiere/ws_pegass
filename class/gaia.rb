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
    attr_accessor :jsessionid
     
    def initialize()
        @url_identification = 'https://id.authentification.croix-rouge.fr' # 'https://id.authentification.croix-rouge.fr'
        @url_gaia = 'https://gaia.croix-rouge.fr'
        @agent = Mechanize.new { |a|
            a.post_connect_hooks << lambda { |_,_,response,_|
                if response.content_type.nil? || response.content_type.empty?
                response.content_type = 'text/html'
                end
            }
        }
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
        # puts "Go to #{url_policy}"
        policy_page = @agent.get url_policy
        while policy_page.code[/30[12]/]         
            #gestion error logout
            if policy_page.header['location'].eql? "/my.logout.php3?errorcode=19"
                policy_page = agent.get policy_page.header['location'] 
                # policy_page.links.each do |link|
                #     puts link.inspect 
                # end
                policy_page = @agent.get url_root
            else
                policy_page = @agent.get policy_page.header['location']                        
            end
        end

        # puts "end of first call: #{policy_page.uri}"

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"
      
        page = @agent.submit search_form
        while page.code[/30[12]/]
            # puts page.header['location']
            page = @agent.get page.header['location']
        end

        # puts "end of submit: #{policy_page.uri}"

        # puts "Go to https://gaia.croix-rouge.fr/crf-benevoles/"
        page_gaia = @agent.get 'https://gaia.croix-rouge.fr/crf-benevoles/'
        while page_gaia.code[/30[12]/]
          # puts page_gaia.header['location']
          page_gaia = @agent.get page_gaia.header['location']
        end

        # page_parse = Mechanize::Page.new(page_gaia.uri,nil,page_gaia.body)

        # puts page_parse.class
        # puts page_parse.inspect
        # puts page_parse.forms.inspect

        search_form = page_gaia.forms.first
        page_fin = @agent.submit search_form

        # html_doc = Nokogiri::HTML(page_gaia.body)
        # html_input = html_doc.at_css "input"

        # data = "SAMLResponse="+html_input.attributes["value"]+"&RelayState=http://gaia.croix-rouge.fr/crf-benevoles/"
        # data_encode=URI.escape(data)
        # puts data_encode

        # puts "Go to https://gaia.croix-rouge.fr/crf-benevoles/saml2/acs" 
        # page_fin = @agent.post "https://gaia.croix-rouge.fr/crf-benevoles/saml2/acs", data_encode, {'Content-Type' => 'application/x-www-form-urlencoded'}
        
        # puts page_fin.inspect        
        # displayCookies()

        boolConnect = false                  
        result = {}
        last = ""
        session = ""        

        @agent.cookie_jar.each do |cookie|  
            if cookie.to_s.include? 'SAML'
                result = callUrl('/crf-benevoles/users/userSession') 
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
          result = callUrl('/crf-benevoles/users/userSession')
          result['SAML']=@saml
          result['JSESSIONID']=@jsessionid
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
        # puts page.body        
        return JSON.parse(page.body)
    end
    
    def putUrl(path, data)
        url_path = @url_gaia + path             
        page = @agent.put url_path, data.to_json, {'Content-Type' => 'application/json'}
        puts page.inspect
        return page.code
    end

    def postUrl(path, data)
        url_path = @url_gaia + path             
        page = @agent.post url_path, data.to_json, {'Content-Type' => 'application/json'}
        puts page.inspect
        return page.code
    end
end
