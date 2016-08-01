require 'net/http'
require 'mechanize'
require 'json'

class PegassMock
    
    attr_accessor :data
    attr_accessor :data_attempt
    
    
    attr_accessor :f5
    attr_accessor :last
    attr_accessor :session
     
    def initialize()
    end

    def connect(username, password)                
        result = {}
        @last = "lastToken"
        @session = "Token"
        @f5 = "F5Token"       
        
        result['LastMRH_Session']=@last
        result['MRHSession']=@session
        result['F5_ST']=@f5
        result['state']=true
        result['admin']= {
            :peutAdministrer => true
        }
         
        return result, boolConnect
    end
    
    def f5connect(token, last, session)  
        
        result = {}
        @last = last
        @session = session
        @f5 = token    
        
        result['LastMRH_Session']=@last
        result['MRHSession']=@session
        result['F5_ST']=@f5
        result['state']=true
        result['admin']= {
            :peutAdministrer => true
        }
         
        return result, boolConnect
    end    
    
    def callUrl(path)
        return @data
    end
    
    def putUrl(path, data)
        return 200
    end
end