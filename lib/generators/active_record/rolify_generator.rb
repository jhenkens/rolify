require 'rails/generators/active_record'
require 'active_support/core_ext'

module ActiveRecord
  module Generators
    class RolifyGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :user_cnames, :type => :array, :banner => "User UserClass2 ...", :default => ["User"]
      
      def generate_model
        invoke "active_record:model", [ name ], :migration => false
      end
      
      def inject_role_class
        inject_into_class(model_path, class_name, model_content)
      end
      
      def copy_rolify_migration
        migration_template "migration.rb", "db/migrate/rolify_create_#{table_name}.rb"
      end

      def migration_join_table_params
        if block_given?
          user_tables = join_tables.zip(user_references)
          user_tables.each do |table|
            yield *table
          end
        end
      end

      def join_tables
        user_cnames.map{ |x| x.constantize.table_name + "_" + table_name }
      end

      def user_references
        user_cnames.map{ |x| x.demodulize.underscore }
      end

      def user_table_names
        user_cnames.map{|x| x.constantize.table_name }
      end
      
      def role_reference
        class_name.demodulize.underscore
      end

      def model_path
        File.join("app", "models", "#{file_path}.rb")
      end
      
      def model_content
        content = "\n"
        user_table_names.zip(join_tables).each do |user_cname, join_table|
          content += "  has_and_belongs_to_many :#{user_cname}, :join_table => :#{join_table}\n"
        end
        content += <<RUBY

  belongs_to :resource, :polymorphic => true
  
  scopify
RUBY
        content
      end
    end
  end
end
