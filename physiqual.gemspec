$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'physiqual/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'physiqual'
  s.version     = Physiqual::VERSION
  s.authors     = ['Frank Blaauw', 'Ando Emerencia', 'Maria Schenk']
  s.email       = ['frank.blaauw@gmail.com', 'ando.emerencia@gmail.com', 'h.m.schenk@umcg.nl']
  s.homepage    = 'http://physiqual.com'
  s.summary     = 'Ruby Engine for merging various datasources with diary questionnaire data'
  s.description = 'Ruby Engine for merging various datasources with diary questionnaire data'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.4'

  s.add_dependency 'oauth2'
  s.add_dependency 'httparty'
  s.add_dependency 'active_interaction', '~> 2.1.2'

  # imputation
  s.add_dependency 'spliner'
  s.add_dependency 'interpolator'

  # Jquery
  s.add_dependency 'jquery-rails'

  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'

  s.add_development_dependency 'webmock'

  # For some reason I was not able to run the migrations with these gems installed
  s.add_development_dependency 'spring'
  s.add_development_dependency 'spring-commands-rspec'

  s.add_development_dependency 'rubocop'

  # freeze and change time for tests
  s.add_development_dependency 'timecop'

  # vcr to capture service responses
  s.add_development_dependency 'vcr'
end
