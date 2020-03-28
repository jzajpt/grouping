require_relative 'lib/grouping/version'

Gem::Specification.new do |spec|
  spec.name          = "grouping"
  spec.version       = Grouping::VERSION
  spec.authors       = ["Jiri Zajpt"]
  spec.email         = ["jzajpt@users.noreply.github.com"]

  spec.summary       = %q{Programming Exercise - Grouping}
  spec.description   = %q{Identify rows in a CSV file that may represent the same person based on a provided Matching Type}
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = "https://www.github.com/jzajpt/grouping"
  spec.metadata["source_code_uri"] = "https://www.github.com/jzajpt/grouping"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
