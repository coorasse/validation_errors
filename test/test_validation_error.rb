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

  def test_that_models_can_track_on_create
    TrackedBook.create(title: "")
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_nil ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end

  def test_that_models_can_track_on_create_bang
    begin
      TrackedBook.create!(title: "")
    rescue
      ActiveRecord::RecordInvalid
    end
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_nil ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end

  def test_that_models_do_not_track_on_create_if_no_errors
    TrackedBook.create(title: "The Hobbit")
    assert_equal 0, ValidationError.count
  end

  def test_that_models_can_track_on_update
    book = TrackedBook.create(title: "The Hobbit")
    book.update(title: "")
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_equal book.id, ValidationError.first.invalid_model_id
    assert_equal "update", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end

  def test_that_models_can_track_on_update_bang
    book = TrackedBook.create(title: "The Hobbit")
    begin
      book.update!(title: "")
    rescue
      ActiveRecord::RecordInvalid
    end
    assert_equal 1, ValidationError.count
    assert_equal "TrackedBook", ValidationError.first.invalid_model_name
    assert_equal book.id, ValidationError.first.invalid_model_id
    assert_equal "update", ValidationError.first.action
    assert_equal({"title" => [{"error" => "blank"}]}, ValidationError.first.details)
  end

  def test_that_models_do_not_track_on_update_if_no_errors
    book = TrackedBook.create(title: "The Hobbit")
    book.update(title: "Harry Potter")
    assert_equal 0, ValidationError.count
  end

  module RailsMock
    def self.application
      @application ||= OpenStruct.new(config: OpenStruct.new(filter_parameters: [:password, :ssn]))
    end
  end

  def test_that_it_does_not_track_password
    # Temporarily replace Rails with RailsMock
    Object.const_set(:Rails, RailsMock)

    invalid_user = User.new(username: "alex", password: "thisissecret")
    invalid_user.valid?
    ValidationError.track(invalid_user)
    assert_equal 1, ValidationError.count
    assert_equal "User", ValidationError.first.invalid_model_name
    assert_nil ValidationError.first.invalid_model_id
    assert_equal "create", ValidationError.first.action
    assert_equal({"password" => [{"error" => "invalid", "value" => "***"}]}, ValidationError.first.details)
    assert_equal("thisissecret", invalid_user.errors.details[:password][0][:value])
  end
end
