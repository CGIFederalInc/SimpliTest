#Example: Given I am on the "home" page
Given /^(?:|I )am on the "(.*)" (?:page|Page)$/ do |page_name|
  visit path_to(page_name)
  maximize_window
end

#Example: When  I go to the "other" page
When /^(?:|I )go to the "(.*)" page$/ do |page_name|
  visit path_to(page_name)
end

#Example: When I follow "Privacy Policy"
When /^(?:|I )follow "([^"]*)"$/ do |link|
  patiently { click_link(link) }
end

#Example: When I maximize the window
And /^(?:|I )maximize the window$/ do
  maximize_window
end

#Example: And I switch to the last window
And /^(?:|I )switch to the (.*) window$/ do |first_or_last|
  change_window(first_or_last)
end


#Example: And I switch to the frame
And /^(?:|I )[Ss]witch to the frame$/ do
  page.driver.browser.switch_to.frame(1)
end

# Accepts modal popups if they exist or fails gracefully if not

#Example: Then I Accept the popup window
Then /^(?:|I )[Aa]ccept (?:|the )popup(?:| window)$/ do
  page.driver.browser.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertPresentError
end

#Dismisses modal popups if they exist or fails gracefully if not

#Example: Then I Dismiss the popup window
Then /^(?:|I )[Dd]ismiss (?:|the )popup(?:| window)$/ do
  page.driver.browser.switch_to.alert.dismiss rescue Selenium::WebDriver::Error::NoAlertPresentError
end


#Example: And I switch to the iframe
And /^(?:|I )[Ss]witch to the iframe$/ do
  page.driver.browser.switch_to.frame(0)
end

#Example: And I switch to the last_iframe
And /^(?:|I )[Ss]witch to the last_iframe$/ do
  page.driver.browser.switch_to.parent_frame
    
end
#-------------------------------------------------------
