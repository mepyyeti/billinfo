
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "billinfo/version"

Gem::Specification.new do |spec|
  spec.name          = "billinfo"
  spec.version       = Billinfo::VERSION
  spec.authors       = ["mepyyeti"]
  spec.email         = ["rcabej@gmail.com"]

  spec.summary       = %q{A bill repository. Organizes monthly bills by category. Calculates inclusive/exclusive means. Sums categories.}
  spec.homepage      = "https://www.github.com/mepyyeti/billinfo"
  spec.files	     = 'git ls-files'.split($/)
  spec.require_paths = ["lib"]
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://rubygems.org'

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.5.0", ">= 10.5.0"
  spec.add_runtime_dependency "sqlite3", "~> 1.4.0", ">= 1.4.0"
  spec.post_install_message = "thx.  https://www.github.com/mepyyeti/billinfo"
end
