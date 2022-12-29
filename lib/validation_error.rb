# frozen_string_literal: true

class ValidationError < ActiveRecord::Base
  def self.track(invalid_model, action: invalid_model.persisted? ? "update" : "create")
    create!(invalid_model_name: invalid_model.class.name,
            invalid_model_id: invalid_model.id,
            details: invalid_model.errors.details,
            action: action)
  end
end
