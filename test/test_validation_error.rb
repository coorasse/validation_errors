# frozen_string_literal: true

require "test_helper"

class TestValidationError < Minitest::Test
  def teardown
    Book.delete_all
    ValidationError.delete_all
  end

  def test_that_it_can_track_model_errors
    invalid_book = Book.new(id: 2)
    invalid_book.errors.add(:base, :invalid)
    invalid_book.errors.add(:title, :blank)
    invalid_book.errors.add(:title, :invalid)
    ValidationError.track(invalid_book)
    assert_equal 1, ValidationError.count
    assert_equal "Book", ValidationError.first.invalid_model_name
    assert_equal 2, ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"base" => [{"error" => "invalid"}],
                  "title" => [{"error" => "blank"}, {"error" => "invalid"}]}, ValidationError.first.details)
    # assert_equal 3, FlatValidationError.count
  end

  def test_that_it_can_track_model_errors_with_custom_action_name
    invalid_book = Book.new(id: 2)
    invalid_book.errors.add(:base, :invalid)
    ValidationError.track(invalid_book, action: "import")
    assert_equal 1, ValidationError.count
    assert_equal "Book", ValidationError.first.invalid_model_name
    assert_equal "import", ValidationError.first.action
  end

  def test_that_models_can_track_on_save
    invalid_book = TrackedBook.new
    invalid_book.save
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_nil ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end

  def test_that_models_can_track_on_save_bang
    invalid_book = TrackedBook.new
    begin
      invalid_book.save!
    rescue
      ActiveRecord::RecordInvalid
    end
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_nil ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end
end
