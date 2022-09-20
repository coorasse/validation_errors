# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "validation_errors"

require "minitest/autorun"

class Book < ActiveRecord::Base
end

class TrackedBook < ActiveRecord::Base
  track_validation_errors

  self.table_name = "books"

  validates :title, presence: true
end

# ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :books do |t|
    t.string :title
    t.string :author
    t.timestamps null: false
  end

  create_table :validation_errors do |t|
    t.string :invalid_model_name
    t.bigint :invalid_model_id
    t.string :action
    t.json :details
    t.timestamps null: false
  end
end
