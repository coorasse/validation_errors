# frozen_string_literal: true

require "rails/generators/base"
require "rails/generators/migration"

module ValidationErrors
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../../templates", __FILE__)

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      desc "Copy migrations to your application."
      def copy_migrations
        migration_template "create_validation_errors_table.rb", "db/migrate/create_validation_errors_table.rb"
        if defined?(Scenic)
          migration_template "create_flat_validation_errors.rb", "db/migrate/create_flat_validation_errors.rb"
          copy_file "flat_validation_errors_v01.sql", "db/views/flat_validation_errors_v01.sql"
        else
          puts "Scenic is not installed so we will skip the creation of the flat_validation_errors view.\nCheck the README for more information."
        end
      end
    end
  end
end
