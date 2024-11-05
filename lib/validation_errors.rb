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
      def save(**options)
        super.tap do |result|
          Thread.new { ValidationError.track(self) }.join unless result
        end
      end

      # Attempts to save the record just like {ActiveRecord::Base#save}[rdoc-ref:Base#save] but
      # will raise an ActiveRecord::RecordInvalid exception instead of returning +false+ if the record is not valid.
      def save!(**options)
        super
      rescue ActiveRecord::RecordInvalid
        Thread.new { ValidationError.track(self) }.join
        raise
      end
    end
  end
end

ActiveRecord::Base.include ValidationErrors::Trackable
