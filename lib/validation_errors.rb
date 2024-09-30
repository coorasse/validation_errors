# frozen_string_literal: true

require "active_record"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.collapse("#{__dir__}/validation_errors")
loader.ignore("#{__dir__}/generators")
loader.setup

module ValidationErrors
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
      def update(**attributes)
        super.tap do |result|
          ValidationError.track(self) unless result
        end
      end

      def update!(**attributes)
        super
      rescue ActiveRecord::RecordInvalid
        ValidationError.track(self)
        raise
      end

      def save(**options)
        super.tap do |result|
          ValidationError.track(self) unless result
        end
      end

      # Attempts to save the record just like {ActiveRecord::Base#save}[rdoc-ref:Base#save] but
      # will raise an ActiveRecord::RecordInvalid exception instead of returning +false+ if the record is not valid.
      def save!(**options)
        super
      rescue ActiveRecord::RecordInvalid
        ValidationError.track(self)
        raise
      end
    end
  end
end

ActiveRecord::Base.include ValidationErrors::Trackable
