require 'capybara'
require 'capybara/cucumber'
require 'capybara/dsl'
require 'rspec'
require "nokogiri"
require 'open-uri'
require_relative './local_environment'
require_relative './screen_size'
require_relative './steps'
require File.join(SimpliTest.path_to_helpers_dir, 'project_setup')
RSpec.configure do |config|
  config.include Capybara::DSL
end

Capybara.save_and_open_page_path = File.expand_path(File.join(SimpliTest.config_support_directory,'../../tmp')) if SimpliTest.config[:support_directory]
Capybara.default_max_wait_time = 2

driver = SimpliTest.driver #default is selenium
profiles_dir = File.join(File.dirname(__FILE__), 'profiles')
profiles = {
  'phantomjs' => 'phantom',
  'phantom_debug' => 'phantom_debug',
  'chrome' => 'chrome',
  'selenium' => 'selenium',
  'ie' => 'internet_explorer',
  'firefox' => 'firefox'
}
profile = File.join profiles_dir, profiles[driver]
require profile
puts "Loaded Environment"



#Leave the window open after a test fails if this tag is provided
After('@leave_the_window_open') do |scenario|
  if scenario.respond_to?(:status) && scenario.status == :failed
    print "Step Failed. Press Return to close browser"
    STDIN.getc
  end
end

Before do |s|
#  if SimpliTest.env_or_setting('JIRA_INTEGRATION_ENABLED') && SimpliTest.env_or_setting('JIRA_URL')
 #   $has_jira_info ||= false
 #   return $has_jira_info if $has_jira_info
 #   $jira = SimpliTest::JiraIntegration.load_project_details
 #   $has_jira_info = true
 # end
end

After do |s|

  #Reuse Browser sessions
if SimpliTest.config[:settings]['REUSE_BROWSER_SESSIONS']
  Capybara.current_session.instance_variable_set('@touched', !SimpliTest.config[:settings]['REUSE_BROWSER_SESSIONS'])
else
  Capybara.current_session.instance_variable_set('@touched', true)
end  

  # Tell Cucumber to quit after this scenario is done - if it failed.
        #Cucumber.wants_to_quit = true if SimpliTest.config[:settings][QUIT_ON_FAIL] && s.failed?
        #zephyr_reporter = SimpliTest::JiraIntegration.new(s)
        #zephyr_reporter.report
end



