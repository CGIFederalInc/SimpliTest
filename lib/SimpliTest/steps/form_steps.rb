# Use this to fill in an entire form with data from a table. Example:
#
#     When I fill in the following:
#     | Account Number                  | 5002       |
#     | Expiry date                     | 2009-11-01 |
#     | Note                            | Nice guy   |
#     | Wants Email?                    |            |
#     | Sex                  (select)   | Male       |
#     | Accept user agrement (checkbox) | check      |
#     | Send me letters      (checkbox) | uncheck    |
#     | radio 1              (radio)    | choose     |
#     | Avatar               (file)     | avatar.png |
#
#Example: When I fill in the following:
When /^(?:|I )fill in the following:$/ do |fields|

  select_tag    = /^(.+\S+)\s*(?:\(select\))$/
  check_box_tag = /^(.+\S+)\s*(?:\(checkbox\))$/
  radio_button  = /^(.+\S+)\s*(?:\(radio\))$/
  file_field    = /^(.+\S+)\s*(?:\(file\))$/

  fields.rows_hash.each do |name, value|
    case name
    when select_tag
      step %(I select "#{value}" from "#{$1}")
    when check_box_tag
      case value
      when 'check'
        step %(I check "#{$1}")
      when 'uncheck'
        step %(I uncheck "#{$1}")
      else
        raise 'checkbox values: check|uncheck!'
      end
    when radio_button
      step %{I choose "#{$1}"}
    when file_field
      #step %{I attach the file "#{value}" to "#{$1}"}
    else
      step %{I fill in "#{name}" with "#{value}"}
    end
  end
end

#************************ UPLOAD A FILE *****************************************
#Example: When I attach the file "sample.txt" to "field_name"
When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |file, field|
  dir = File.join(SimpliTest.config_support_directory, 'files', 'attachments')
  FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  path = File.join(dir, file)
  raise RuntimeError, "file '#{path}' does not exists" unless File.exists?(path)
  attach_file(field, path)
end

#************************ UPLOAD A FILE *****************************************

#************************ TEXT FIELDS ********************************************


#Example: When I fill in "Name" with "my name"
When /^(?:|I )fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
  selector, selector_type = selector_for(field)
  if ['xpath', 'css'].include?(selector_type)
    patiently do
      element = find(selector_type.to_sym, selector)
      element.set value
    end
  else
    patiently { fill_in(field, :with => value) }
  end
end

#TODO: Deprecate the step below
#Example: See Gist
When /^(?:|I )fill in "([^"]*)" with:$/ do |field, value|
  selector, selector_type = selector_for(field)
  if ['xpath', 'css'].include?(selector_type)
    patiently do
      element = find(selector_type.to_sym, selector)
      element.set value
    end
  else
    patiently { fill_in(field, :with => value) }
  end
end

#Example:  And I enter "I made this" in the "Describe yourself" field
When /^I enter "(.*?)" in the "(.*?)" field$/ do |value, field|
  patiently do
    step %Q{I fill in "#{field}" with "#{value}"}
    step %Q{I move focus away from "#{field}"}
  end
end

#TODO: Clean this code up, blur should handle xpath and name attributes as well
#Example: Then I key in the date "12/01/2013" in the "Date" field
When /^I key in the date "(.*?)" in the "(.*?)" field$/ do |date_rule, field|
  selector, selector_type = selector_for(field)
  value = calculated_date_from(date_rule)
  raise "xpath is not yet supported for masked input. Please use the css selector instead" if selector_type == 'xpath'
  patiently do
    field = get_element_from(selector)
    field.set(value)
  end
end

#Example: When I key in "22031" in the "Location" field
When /^I key in "(.*?)" in the "(.*)" field$/ do |text, field|
  selector, selector_type = selector_for(field)
  if selector_type == 'other'
    element = find_field(selector)
  else
    element = find(selector_type.to_sym, selector) 
  end
  key_in text, element
end


#************************ END TEXT FIELDS ****************************************


#************************ DROP DOWNS**********************************************


#Example: When I select "Male" from "Sex"
When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, select_field_name_id_or_text|
  selector, selector_type = selector_for(select_field_name_id_or_text)
  if selector_type == 'other'
    patiently { select(value, :from => select_field_name_id_or_text) }
  else
    field = find(selector_type.to_sym, selector)
    patiently { field.select value }
  end
end


#************************ END DROP DOWNS******************************************


#************************ CHECKBOXES *********************************************


#Example: And I check "Accept user agrement"
When /^(?:|I )check "([^"]*)"$/ do |field|
  selector, selector_type = selector_for(field)
  if selector_type == 'other'
    patiently { check(field) }
  else 
    field = find(selector_type.to_sym, selector)
    field.set(true)
  end
end

#Example: When I uncheck "Send me letters"
When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  patiently { uncheck(field) }
end


#************************ END CHECKBOXES******************************************


#************************ MULTI SELECT BOXES *************************************


#Example: When I select following values from "Filters": Accepts Gherkin Table
When /^(?:I|i) select following values from "([^"]*)":$/ do |field, values|
  values = values.transpose.raw
  if values.size > 1
    raise 'table should have only one column in this step!'
  else
    values = values.first
  end

  values.each do |value|
    patiently { select(value, :from => field) }
  end
end

#Example: When I unselect following values from "Filters": Accepts Gherkin Table
When /^(?:I|i) unselect following values from "([^"]*)":$/ do |field, values|
  values = values.transpose.raw
  if values.size > 1
    raise 'table should have only one column in this step!'
  else
    values = values.first
  end

  values.each do |value|
    patiently { unselect(value, :from => field) }
  end
end


#************************ END MULTI SELECT BOXES *********************************


#************************ RADIO BUTTONS*******************************************


#Example: When I choose "radio 1"
When /^(?:|I )choose "([^"]*)"$/ do |field|
  patiently { choose(field) }
end

#************************ END RADIO BUTTONS***************************************


#************************ BUTTONS AND LINKS***************************************


#Example: When I press "Submit"
When /^(?:|I )press "([^"]*)"$/ do |button|
  patiently { click_on(button) }
end
#Example: When I press the 4th instance of "nextButton"
Given /^I press the (first|last|[0-9]+(?:th|st|rd|nd)) instance of "(.*?)"$/ do |index,link|
  index = numerize index
  locator, selector_type = selector_for(link)
  selector_type = selector_type == 'xpath' ? :xpath : :css
  patiently do
    begin
      elements = all(selector_type, locator)
      element = elements[index]
      element.click
    rescue
      raise Capybara::ElementNotFound
    end
  end
end

#Example: When I click the next page button
When /^I click the (first|last|next|previous) page button$/ do |index|
  pagination_element_for(index).click
end


#Example: When I click the "Submit" button
When /^I click the "(.*?)" (?:button|link)$/  do |button_or_link|
  patiently do
    element = get_button_or_link_from(button_or_link)
    click_element(element)
  end
end


#************************ END BUTTONS AND LINKS***********************************


#************************ PAGINATION ***********************************
#Example: When I go to page 1
When /^I go to page (\d+)$/ do |page_number|
  pagination_links_for(page_number).first.click
end


#************************ KEYBOARD EVENTS ****************************************

#Example: Not implemented yet
When /^I move focus away from "(.*)"$/ do |locator|
  element = get_element_from(locator)
  tab_on element
end

#Example: When I press keydown on "LocationCSSSelector"
When /^I press keydown on "(.*)"$/ do |locator|
  #selector, selector_type = selector_for(locator)
  #element = get_element_from(locator)
  #if selector_type == 'css'
    #script = "var e = $.Event('keydown');e.keyCode = 40;$('#{locator}').trigger(e)"
     #script = "var e = $.Event('keydown', { keyCode: 40 }); $('#nameTxtBox').trigger(e)"
    #execute_js script
    #keydown_on(element)
  #else
    #raise "OnlyCSSSelectorsAreSupported"
  #end
end



#************************ END KEYBOARD EVENTS ************************************


#************************ MOUSE EVENTS *******************************************
#Example: And I hover over "BidPlansMenu"
Then /^I hover over "(.*?)"$/ do |locator|
  element = get_element_from(locator)
  element.hover
end

#************************ END MOUSE EVENTS ***************************************

#************************ MODAL AND DIALOGS **************************************


#Example: And I accept the confirmation dialog
When /^I accept the confirmation dialog box$/ do
page.driver.browser.switch_to.alert.accept

  #accept_confirmation
end

#Example: And I switch to the iframe
And /^(?:|I )[Ss]witch to the iframe$/ do
  page.driver.browser.switch_to.frame(0)
end

#************************ END MODAL AND DIALOGS **********************************

#Example: Then I attach file "testAttachment.txt" to "File"
Then /^I attach file "([^"]*)" to "([^"]*)"$/ do |file, field|
dir = File.join(SimpliTest.config_support_directory, 'files', 'attachments')
  FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  path = File.join(dir, file)
   raise RuntimeError, "file '#{path}' does not exists" unless File.exists?(path)
 
 element = get_element_from(field)
element.send_keys(path)
end

# Enter's current date in a field (e.g., 03/01/2016)

#Example: Then I enter today's date in the "date" field"
Then /^(?:|I )[Ee]nter today's date in the "([^"]*)" field$/ do |locator|
  element = get_element_from(locator)
  element.set Date.today.strftime('%m/%d/%Y')
end

#Example: Then I verify "date" field has today's date
Then(/^I verify "([^"]*)" field has today's date$/) do |locator|
  date_td = get_element_from(locator).value
  date_td.should == Date.today.strftime('%m/%d/%Y')
end

#Example: When I right-click "some element" and then click "Some Link" option
When /^I right-click on "(.*?)" and then click the "(.*?)" option$/ do | locator, link|

element = find('.x-grid-cell',:text => locator, :exact => true)
element.right_click
menulink = get_button_or_link_from(link)
click_element(menulink) 

end

#Example: When I click the "Submit" tab
When /^I click the "(.*?)" tab$/  do |button_or_link|
  patiently do
    element = get_button_or_link_from(button_or_link)
    click_element(element)
  end
end

