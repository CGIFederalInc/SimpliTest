
Capybara.register_driver :firefox do |app|
 require 'selenium/webdriver'
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.native_events = true
 Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Before do
  Capybara.current_driver = :firefox
  SimpliTest.driver = 'firefox'
end

World(CustomSeleniumHelpers)
