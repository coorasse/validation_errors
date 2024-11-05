# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "validation_errors"

require "minitest/autorun"

class Book < ActiveRecord::Base
end

class User < ActiveRecord::Base
  validates :password, format: %r{\A[0-9]+\z}
end

class TrackedBook < ActiveRecord::Base
  track_validation_errors

  self.table_name = "books"

  validates :title, presence: true
end

ActiveRecord::Base.logger = Logger.new($stdout)
# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
# connect to a file
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "db/development.sqlite3")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :books, if_not_exists: true do |t|
    t.string :title
    t.string :author
    t.timestamps null: false
  end

  create_table :users, if_not_exists: true do |t|
    t.string :username
    t.string :password
    t.timestamps null: false
  end

  create_table :validation_errors, if_not_exists: true do |t|
    t.string :invalid_model_name
    t.bigint :invalid_model_id
    t.string :action
    t.json :details
    t.timestamps null: false
  end

  # execute <<-SQL
  #         CREATE OR REPLACE VIEW flat_validation_errors AS
  #           select validation_errors.invalid_model_name,
  #                  validation_errors.invalid_model_id,
  #                  validation_errors.action,
  #                  validation_errors.created_at,
  #                  json_data.key as error_column,
  #                  json_array_elements(json_data.value)->>'error' as error_type
  #           from validation_errors, json_each(validation_errors.details) as json_data;
  # SQL
end
