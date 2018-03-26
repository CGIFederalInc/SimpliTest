

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end


Before do
  Capybara.current_driver = :selenium
  SimpliTest.driver = 'selenium'
end

World(CustomSeleniumHelpers)