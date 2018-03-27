# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "SimpliTest"
  spec.version       = SimpliTest::VERSION
  spec.authors       = ["CGI Federal"]
  spec.email         = ["SimpliTest@cgifederal.com"]
  spec.description   = %q{Cucumber Websteps, Helpers and Executable for Web Test Automation }
  spec.summary       = %q{This gem provides common web steps and command line executable for automated acceptance testing }
  spec.homepage      = "https://github.com/CGIFederalInc/SimpliTest"
  spec.license       = "MIT"

  spec.files		 = Dir['lib/**/*'] + Dir['features/**/*'] + Dir['bin/*'] + ["SimpliTest.gemspec","README.md"] + Dir['test/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "rubygems-update", "2.6.11"
  spec.add_dependency "unf_ext", "0.0.7.2"
  spec.add_dependency "geckodriver-helper", "~> 0.0.4"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "sinatra", "~> 0"
  spec.add_development_dependency "cucumber-sinatra", "~> 0"
  spec.add_development_dependency "rake-notes", "~> 0"
  spec.add_development_dependency "simplecov", "~> 0"
  spec.add_development_dependency "aruba", "~> 0"
  spec.add_development_dependency "hirb", "~> 0"
  spec.add_development_dependency "geminabox", "~> 0"

  spec.add_dependency "rake", "~> 10.4"
  spec.add_dependency "cucumber", "2.1.0"
  spec.add_dependency "poltergeist", "1.7.0"
  spec.add_dependency "capybara", "2.5"
  spec.add_dependency "rspec", "~> 3.7"
  spec.add_dependency "selenium-webdriver", "~> 3.2"
  spec.add_dependency "launchy", "~> 2.4"
  spec.add_dependency 'parallel_tests', "~> 1.9"
  spec.add_dependency 'tiny_tds', "~> 2.0"
  spec.add_dependency 'rest-client', "~> 0"
  spec.add_dependency "axe-matchers", "~> 2.0", ">= 2.0.0"
  end