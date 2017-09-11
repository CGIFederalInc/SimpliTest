if SimpliTest.chromedriver_detected?
  require 'selenium/webdriver'
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  Before do
    Capybara.current_driver = :chrome
    Capybara.javascript_driver = :chrome
  end

  World(CustomSeleniumHelpers)
  World(CustomChromeHelpers)
else
  alert "Could not find ChromeDriver. Please make sure it is installed and try again"
end


