# frozen_string_literal: true

class FlatValidationError < ActiveRecord::Base
  def readonly?
    true
  end
end
