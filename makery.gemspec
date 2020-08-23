lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "makery/version"

Gem::Specification.new do |spec|
  spec.name          = "makery"
  spec.version       = Makery::VERSION
  spec.authors       = ["Kelly Wolf Stannard"]
  spec.email         = ["kwstannard@gmail.com"]

  spec.summary       = "A minimalist factory gem"
  spec.description   = "A minimalist factory gem"
  spec.homepage      = "https://github.com/kwstannard/makery"
  spec.required_ruby_version = '>= 2.3'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.glob("lib/**/*.rb")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop", "0.89.1"
  spec.add_development_dependency "rubocop-rspec", "1.43.1"
  spec.add_development_dependency "simplecov"
end
