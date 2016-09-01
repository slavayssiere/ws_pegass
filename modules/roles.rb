require 'sinatra/base'
require_relative '../class/pegass'
require_relative '../class/roles'

module Sinatra
  module PegassApp
    module Roles
        def self.registered(app)

            app.get '/benevoles/roles/:role' do
                begin
                    role = RolesClass.new(get_connexion['pegass'])
                    role_ret = role.listStructureWithRole(params['role'], params['ul'], params['page'])
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{role_ret.to_json}"
            end

            app.get '/benevoles/roles' do
                begin
                    role = RolesClass.new(get_connexion['pegass'])
                    role_ret = role.getRoles();
                    status 200
                rescue => exception
                    puts exception
                    status 500
                end
                
                "#{role_ret.to_json}"
            end
        end
    end
  end 
end
