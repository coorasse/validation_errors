# frozen_string_literal: true

require "active_record"

class ValidationErrors < ActiveRecord::Base
  VERSION = "0.1.0"

  def self.track(invalid_model)
    create!(invalid_model_name: invalid_model.class.name,
            invalid_model_id: invalid_model.id,
            details: invalid_model.errors.details,
            action: invalid_model.persisted? ? "update" : "create")
  end

  module Trackable
    def self.included(base)
      base.extend ClassMethods
    end

    # :nodoc:
    module ClassMethods
      def track_validation_errors
        include InstanceMethods
      end
    end

    module InstanceMethods
      def save(**options)
        super.tap do |result|
          ValidationErrors.track(self) unless result
        end
      end

      # Attempts to save the record just like {ActiveRecord::Base#save}[rdoc-ref:Base#save] but
      # will raise an ActiveRecord::RecordInvalid exception instead of returning +false+ if the record is not valid.
      def save!(**options)
        super
      rescue ActiveRecord::RecordInvalid
        ValidationErrors.track(self)
        raise
      end
    end
  end
end

ActiveRecord::Base.include ValidationErrors::Trackable
