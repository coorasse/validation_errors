# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "validation_errors"
  spec.version = "0.1.0"
  spec.authors = ["Alessandro Rodi"]
  spec.email = ["rodi@hey.com"]

  spec.summary = "Track ActiveRecord validation errors on database"
  spec.description = "Easily track all the validation errors on your database so that you can analyse them."
  spec.homepage = "https://github.com/coorasse/validation_errors"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/coorasse/validation_errors"
  spec.metadata["changelog_uri"] = "https://github.com/coorasse/validation_errors/blob/main/CHANGELOG.md"
  spec.metadata["funding_uri"] = "https://github.com/sponsors/coorasse"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activerecord", ">= 4.1.0"
  spec.add_dependency "zeitwerk", ">= 2.0.0"

  spec.add_development_dependency "sqlite3", "~> 1.5.0"
  spec.add_development_dependency "standard", "~> 0.13.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
