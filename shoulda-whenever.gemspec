$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require 'shoulda/whenever/version'

Gem::Specification.new do |s|
  s.name        = "shoulda-whenever"
  s.version     = Shoulda::Whenever::VERSION.dup
  s.authors     = ["Matthew Gerrior"]
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.email       = "gerrior.matthew@gmail.com"
  s.homepage    = "http://rubygems.org/gems/shoulda-whenever"
  s.summary     = "Shoulda style matchers for whenever gem"
  s.license     = "MIT"
  s.description = "This gem is designed to make it easier to test that the schedule you built with the 'whenever' gem is accurate."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.3.8'

  s.add_development_dependency "rspec", "~> 3.7"
  s.add_development_dependency "whenever", "~> 0.10"
  s.add_development_dependency "activesupport", "~> 5.2"
end
