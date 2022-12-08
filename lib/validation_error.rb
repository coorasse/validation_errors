# frozen_string_literal: true

class ValidationError < ActiveRecord::Base
  def self.track(invalid_model)
    create!(invalid_model_name: invalid_model.class.name,
            invalid_model_id: invalid_model.id,
            details: invalid_model.errors.details,
            action: invalid_model.persisted? ? "update" : "create")
  end
end
