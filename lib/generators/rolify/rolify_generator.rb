module Rolify
  module Generators
    class RolifyGenerator < Rails::Generators::NamedBase
      Rails::Generators::ResourceHelpers
      
      source_root File.expand_path('../templates', __FILE__)
      argument :user_cnames, :type => :array, :banner => "User UserClass2 ...", :default => ["User"]

      namespace :rolify
      hook_for :orm, :required => true

      desc "Generates a model with the given NAME and a migration file."

      def self.start(args, config)
        super
      end
      
      def inject_user_class
        user_cnames.each do |cname|
          Rails::Generators.invoke "rolify:user", [ cname, class_name ], :orm => options.orm, behavior: behavior, destination_root: destination_root
        end

      end
        
      def copy_initializer_file
        template "initializer.rb", "config/initializers/rolify.rb"
      end
      
      def show_readme
        if behavior == :invoke
          readme "README"
        end
      end
    end
  end
end
