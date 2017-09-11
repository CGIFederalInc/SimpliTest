# coding: UTF-8
# :nocov:
module ToleranceForSyncIssues
  RETRY_ERRORS = %w[Capybara::ElementNotFound Capybara::ExpectationNotMet
  Spec::Expectations::ExpectationNotMetError RSpec::Expectations::ExpectationNotMetError
  Capybara::Poltergeist::ClickFailed Selenium::WebDriver::Error::StaleElementReferenceError
  Selenium::WebDriver::Error::NoAlertPresentError Capybara::Poltergeist::JavascriptError
  Capybara::Driver::Webkit::WebkitInvalidResponseError Capybara::Webkit::InvalidResponseError]

  # This is similiar but not entirely the same as Capybara::Node::Base#wait_until or Capybara::Session#wait_until
  def patiently(seconds=Capybara.default_max_wait_time, &block)
    #puts "Tried waiting"
    old_wait_time = Capybara.default_max_wait_time
    # dont make nested wait_untils use up all the alloted time
    Capybara.default_max_wait_time = 0 # for we are a jealous gem
    if page.driver.wait?
      start_time = Time.now
      begin
        block.call
      rescue Exception => e
        raise e unless RETRY_ERRORS.include?(e.class.name)
        puts "Failed: #{e.message}" if SimpliTest.mode == 'DEBUG'
        wait_time = SimpliTest.config_settings ? SimpliTest.config_settings['MAX_WAIT_TIME'] : 5
        raise e if (Time.now - start_time) >= wait_time
        sleep(0.1)
        raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Time.now == start_time
        puts "Retrying..." if SimpliTest.mode == 'DEBUG'
        retry
      end
    else
      block.call
    end
  ensure
    Capybara.default_max_wait_time = old_wait_time
  end
end
# :nocov:
World(ToleranceForSyncIssues)
