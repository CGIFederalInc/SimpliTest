Capybara.register_driver :selenium do |app|
  require 'selenium/webdriver'
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.native_events = true
  Capybara::Selenium::Driver.new(app, :browser => :firefox, profile: profile)
end

Before do
  Capybara.current_driver = :selenium
  SimpliTest.driver = 'selenium'
end

World(CustomSeleniumHelpers)
