require 'shoulda/whenever/version'

Gem::Specification.new do |s|
  s.name        = "shoulda-whenever"
  s.version     = Shoulda::Whenever::VERSION.dup
  s.authors     = ["Matthew Gerrior"]
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.email       = "gerrior.matthew@gmail.com"
  s.summary     = "Shoulda style matchers for whenever gem"
  s.license     = "MIT"
  s.description = "Shoulda style matchers for whenever gem"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency "rspec", "~> 3.3.0"
  s.add_development_dependency "whenever", "~> 0.9.4"
end
