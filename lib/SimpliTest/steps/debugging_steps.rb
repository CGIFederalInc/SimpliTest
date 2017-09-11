#Example: Then show me the page
Then /^show me the page$/ do
  save_and_open_page
end

#Example: And I wait 10 seconds
When /^I wait (\d+) second(?:|s)$/ do |seconds|
  seconds  = seconds.to_i #TODO: Write a God Damned Transformer for this for Christ's sake!!!!!
  sleep(seconds)
end

#Example: And I take a screenshot
And /^I take a screenshot$/ do 
  timestamp = Time.now.strftime('%b_%e_%Y_%m_%M_%p')
  dir = File.join(SimpliTest.config_support_directory, 'files', 'screenshots')
  FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  file_name =  File.join(dir, "screenshot-#{timestamp}") + '.png'
  capture_screenshot file_name
end
