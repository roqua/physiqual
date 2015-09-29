$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "physiqual/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "physiqual"
  s.version     = Physiqual::VERSION
  s.authors     = ["Frank Blaauw"]
  s.email       = ["frank.blaauw@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Physiqual."
  s.description = "TODO: Description of Physiqual."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end