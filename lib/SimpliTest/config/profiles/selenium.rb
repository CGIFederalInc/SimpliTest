
Capybara.register_driver :selenium do |app|
 require 'selenium/webdriver'
 
profile = Selenium::WebDriver::Firefox::Profile.new
proxy = Selenium::WebDriver::Proxy.new(:http => nil)
profile.proxy = proxy
driver = Selenium::WebDriver.for :firefox, :profile => profile

  profile.native_events = true
 Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Before do
  Capybara.current_driver = :firefox
  SimpliTest.driver = 'firefox'
end

World(CustomSeleniumHelpers)
