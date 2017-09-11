require 'capybara/poltergeist'
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true)
end

Before do
  Capybara.current_driver = :poltergeist_debug
  Capybara.javascript_driver = :poltergeist_debug
  SimpliTest.driver = 'poltergeist'
end

World(CustomPhantomjsHelpers)
