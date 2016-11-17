require 'net/http'
require 'mechanize'
require 'json'

class Pegass
    
    attr_accessor :url 
    attr_accessor :agent
    
    attr_accessor :f5
    attr_accessor :last
    attr_accessor :session
     
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
        
        # logger.info "First call"        
        policy_page = @agent.get url_root
        
        # logger.info "Post credential on " + url_policy + " with " + @agent.cookie_jar.inspect
        policy_page = @agent.get url_policy

        search_form = policy_page.form_with :name => "e1"
        search_form.field_with(:name => "username").value  = username
        search_form.field_with(:name => "password").value  = password
        search_form.field_with(:name => "vhost").value = "standard"

        logger.info "tentative de connexion de #{username}"
        
        page = @agent.submit search_form

        boolConnect = false                  
        result = {}
        last = ""
        session = ""
        
        agent.cookie_jar.each do |site|
            if site.to_s.include? 'F5_ST'  
                result = callUrl('/crf/rest/gestiondesdroits') 
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
        end        
        
        result['LastMRH_Session']=@last
        result['MRHSession']=@session
        result['state']=boolConnect
        begin
            result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
            isInTeamFormat, role = getUserInfo(result['utilisateur']['id'])
            result['isInTeamFormat']=isInTeamFormat
            result['role']=role
        rescue => exception
            time1 = Time.new
            logger.error "#{time1.inspect} #{exception}"
        end 
        
        
        timelog = Time.new
        logger.info "#{timelog.inspect} tentative de connexion de #{username}, #{boolConnect}"
        
        return result, boolConnect
    end
    
    def f5connect(token, last, session)  
        
        @f5=token
        @last=last
        @session=session
            
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
          result['admin']= callUrl("/crf/rest/gestiondesdroits/peutadministrerutilisateur/?utilisateur=#{result['utilisateur']['id']}")
          isInTeamFormat, role = getUserInfo(result['utilisateur']['id'])
          result['isInTeamFormat']=isInTeamFormat
          result['role']=role
        rescue => exception
          logger.error exception
          boolConnect = false
        end
        
        return result, boolConnect
    end

    def getUserInfo(nivol)
        listTeamFormat = ['00001376977M', '00001669247X', '00001727030F', '00001701729E', '00001641554W', '00000599352T', '01000000106B']
        isInTeamFormat = false;
        if listTeamFormat.any? { |s| s.include?(nivol) }
            isInTeamFormat = true;
        end

        role = "user"
        if nivol.eql? '00001376977M'
            role = "admin"
        elsif nivol.eql? '00000040109X'
            role = "ddaf" 
        elsif nivol.eql? '00000039302V'
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
        
        agent.cookie_jar.each do |site|
            logger.info site.inspect
        end
    end
    
    def callUrl(path)
        # logger.info "Get " + path
        url_path = @url + path        
        page = @agent.get url_path
        return JSON.parse(page.body)
    end
    
    def putUrl(path, data)
        url_path = @url + path             
        page = @agent.put url_path, data.to_json, {'Content-Type' => 'application/json'}
        return page.code
    end
end
