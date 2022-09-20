# frozen_string_literal: true

require "test_helper"

class TestValidationErrors < Minitest::Test
  def teardown
    Book.delete_all
    ValidationErrors.delete_all
  end

  def test_that_it_has_a_version_number
    refute_nil ::ValidationErrors::VERSION
  end

  def test_that_it_can_track_model_errors
    invalid_book = Book.new(id: 2)
    invalid_book.errors.add(:base, :invalid)
    invalid_book.errors.add(:title, :blank)
    invalid_book.errors.add(:title, :invalid)
    ValidationErrors.track(invalid_book)
    assert_equal 1, ValidationErrors.count
    assert_equal "Book", ValidationErrors.first.invalid_model_name
    assert_equal 2, ValidationErrors.first.invalid_model_id
    assert_equal "create", ValidationErrors.first.action
    assert_equal({"base" => [{"error" => "invalid"}],
                  "title" => [{"error" => "blank"}, {"error" => "invalid"}]}, ValidationErrors.first.details)
  end

  def test_that_models_can_track_on_save
    invalid_book = TrackedBook.new
    invalid_book.save
    assert_equal 1, ValidationErrors.count
    assert_equal "TrackedBook", ValidationErrors.first.invalid_model_name
    assert_nil ValidationErrors.first.invalid_model_id
    assert_equal "create", ValidationErrors.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationErrors.first.details)
  end

  def test_that_models_can_track_on_save_bang
    invalid_book = TrackedBook.new
    begin
      invalid_book.save!
    rescue
      ActiveRecord::RecordInvalid
    end
    assert_equal 1, ValidationErrors.count
    assert_equal "TrackedBook", ValidationErrors.first.invalid_model_name
    assert_nil ValidationErrors.first.invalid_model_id
    assert_equal "create", ValidationErrors.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationErrors.first.details)
  end
end
