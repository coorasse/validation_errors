# ValidationErrors

This gem helps you keep track of the ActiveRecord validation errors that have been triggered on a model.
It will persist them on a `validation_errors` database table the following information:
* time of the error
* model name
* model id (if available)
* action (create/update)
* errors.details (hash)

## Why?

Validation Errors happen. In some applications it might be interesting to keep track of them.
This gem has been extracted from various Ruby On Rails apps where we had this need.

The need was: if we have a validation error, we want to keep track of it...but how?
* We could use a logger, but then we would have to parse the logs to get the information we need.
* We could use an error tracker, like Sentry, but this isn't really an error, is it? If you have many, it might pollute your error tracker.
* We could use a database table, and that's what this gem does.

This gem will keep track of the errors, and give you all the freedom to query it and extract statistics and make analysis.
By analysing from time to time these data, you might found out the following:
* Your UI sucks
* Your validations are too strict
* Your validations are too loose
* Your client-side validations are not working
* Your client-side validations are too loose

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add validation_errors

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install validation_errors

## Usage

Run `bundle exec rails validation_errors:install` to create the migration.

The migration will create a `validation_errors` table. Check the migration for details.

### Manual

You can now manually track errors by calling `ValidationErrors.track`:

```ruby
ValidationErrors.track(your_invalid_model)
```

An example could be the following:

```ruby
def create
    @user = User.new(user_params)
    if @user.save
        redirect_to @user
    else
        ValidationErrors.track(@user)
        render :new
    end
end
```

### Automatic

You can also track validation errors automatically by adding `track_validation_errors` in your model.

```ruby
class User < ApplicationRecord
    track_validation_errors
end
```

by doing so, validation errors are tracked automatically on each `save`, `save!`, `update`, or `update!` call.

### Global

You can of course enable it globally by specifying it in ApplicationRecord directly:

```ruby
class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    track_validation_errors
end
```

We currently don't support (PR welcome):
* enable globally and disable on a specific model `skip_track_validation_errors`
* enable only for specific actions `track_validation_errors only: [:create]`
* disable only for specific actions `track_validation_errors except: [:create]`
* enable only for bang or non-bang methods `track_validation_errors only_bang: true`,  `track_validation_errors only_non_bang: true`


## Query your data

Now that you have installed the gem and started tracking, let's take a look at how the data are persisted and how you can query them.
We store the errors in exactly the same format returned by ActiveRecord `errors.details`.

Given a book, that failed to save because of validation errors, you'll get the following:

| id | invalid_model_name | invalid_model_id | action | details                                                                                               |
|----|--------------------|------------------|--------|-------------------------------------------------------------------------------------------------------|
| 1  | Book               | 1                | create | `{ "base" => [{ "error" => "invalid" }], "title" => [{ "error" => "blank" }, {"error" => "invalid"}] }` |

The following SQL (Postgres only!) can be used to obtain a flattened view. You can use it in your queries, or create a database view:

```sql
select validation_errors.invalid_model_name,
       validation_errors.invalid_model_id,
       validation_errors.action,
       validation_errors.created_at,
       json_data.key as error_column,
       json_array_elements(json_data.value)->>'error' as error_type
from validation_errors, json_each(validation_errors.details) as json_data
```

The result is the following:

| invalid_model_name | invalid_model_id | action | error_column | error_type |
|--------------------|------------------|--------|--------------|------------|
| Book               | 1                | create | base         |  invalid   |
| Book               | 1                | create | title        |  blank     |
| Book               | 1                | create | title        |  invalid   |


Let's now check some useful queries:

### Count the number of errors per day

```sql
select count(*), date(created_at) 
from validation_errors 
group by date(created_at) 
order by date(created_at) desc;
```

Please use [groupdate](https://github.com/ankane/groupdate) for more reliable results when grouping by date.

```ruby
ValidationError.group_by_day(:created_at).count
```

### Count the number of errors per model and attribute

```sql
select validation_errors.invalid_model_name, 
       json_data.key as error_column, 
       json_array_elements(json_data.value)->>'error' as error_type, 
       count(*)
from validation_errors, 
     json_each(validation_errors.details) as json_data
group by 1, 2, 3
order by 4 desc
```

or, if you have the view above:

```sql
select invalid_model_name, error_column, count(*)
from validation_errors_flat
group by 1, 2
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coorasse/validation_errors. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/coorasse/validation_errors/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ValidationErrors project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/coorasse/validation_errors/blob/master/CODE_OF_CONDUCT.md).
