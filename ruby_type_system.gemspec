# frozen_string_literal: true

require_relative "lib/ruby_type_system/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_type_system"
  spec.version = RubyTypeSystem::VERSION
  spec.authors = ["Aram"]
  spec.email = ["aramhrptn@hotmail.com"]

  spec.summary = "A typescript implementation for Ruby programming language."
  spec.description = "Ever wanted to have typescript in Ruby? Well, now you can!"
  spec.homepage = "https://rts.svck.dev"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
