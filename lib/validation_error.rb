# frozen_string_literal: true

class ValidationError < ActiveRecord::Base
  def self.track(invalid_model, action: invalid_model.persisted? ? "update" : "create")
    details = filter_sensible_information(invalid_model.errors.details)
    create!(invalid_model_name: invalid_model.class.name,
            invalid_model_id: invalid_model.id,
            details: details,
            action: action)
  end

  def self.filter_sensible_information(details)
    filter_parameters = if defined?(Rails) && Rails.respond_to?(:application)
      Rails.application.config.filter_parameters.map(&:to_sym)
    else
      []
    end
    filtered_details = details.dup
    filtered_details.each do |column_name, errors|
      if filter_parameters.include?(column_name.to_sym)
        errors.each do |error|
          if error[:value].present?
            error[:value] = "***"
          end
        end
      end
    end
    filtered_details
  end
end
