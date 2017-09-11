require 'capybara/poltergeist'
Before do
  Capybara.current_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  SimpliTest.driver= 'poltergeist'
end

World(CustomPhantomjsHelpers)

