module Rolify
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find_roles(role_name = nil, user = nil)
        roles = user && (user != :any) ? user.roles : self.role_class
        roles = roles.where(:resource_type => self.to_s)
        roles = roles.where(:name => role_name.to_s) if role_name && (role_name != :any)
        roles
      end
      alias :resource_find_roles :find_roles

      def with_role(role_name, user = nil)
        if role_name.is_a? Array
          role_name.map!(&:to_s)
        else
          role_name = role_name.to_s
        end
        resources = self.resource_adapter.resources_find(self.role_table_name, self, role_name)
        user ? self.resource_adapter.in(resources, user, role_name) : resources
      end
      alias :with_roles :with_role
      alias :resource_with_role :with_role
      alias :resource_with_roles :with_role
    end

    def applied_roles
      self.resource_roles + self.class.role_class.where(:resource_type => self.class.to_s, :resource_id => nil)
    end
  end
end
