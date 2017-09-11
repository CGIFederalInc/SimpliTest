
Capybara.register_driver :internet_explorer do |app|
 require 'selenium/webdriver'
 Capybara::Selenium::Driver.new(app, :browser => :internet_explorer)
end

Before do
  Capybara.current_driver = :internet_explorer
  SimpliTest.driver = 'internet_explorer'
end

World(CustomSeleniumHelpers)