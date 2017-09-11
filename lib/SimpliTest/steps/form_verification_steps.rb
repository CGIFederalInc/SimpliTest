
#************************ TEXT FIELDS ********************************************

#Example: Then the "Name" field should contain "my name"
Then /^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = get_element_from(field)
    field_value = field.value
    patiently { field_value.should =~ /#{value}/ }
  end
end

#Example: And the "Name" field should not contain "not my name"  
Then /^the "([^"]*)" field(?: within (.*))? should not contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = get_element_from(field)
    field_value = field.value
    patiently { field_value.should_not =~ /#{value}/ }
  end
end


#************************ END TEXT FIELDS ****************************************


#************************ DROP DOWNS *********************************************


#Example: Then the select "Your favorite colors": Table
Then /^the select "([^"]*)" should have following options:$/ do |field, options|
  options = options.transpose.raw
  if options.size > 1
    raise 'table should have only one column in this step!'
  else
    options = options.first
  end

  actual_options = get_element_from(field).all('option').map { |option| option.text }
  patiently { options.should eq(actual_options) }
end

#Example: And the following values should be selected in "Your favorite colors": Table 
Then /^the following values should be selected in "([^"]*)":$/ do |select_box, values|
  values = values.transpose.raw
  if values.size > 1
    raise 'table should have only one column in this step!'
  else
    values = values.first
  end

  select_box= get_element_from(select_box)
  unless select_box['multiple']
    raise "this is not multiple select box!"
  else
    values.each do |value|
      patiently { select_box.value.should include(value) }
    end
  end
end

#Example: And the following values should not be selected in "Your favorite colors":
Then /^the following values should not be selected in "([^"]*)":$/ do |select_box, values|
  values = values.transpose.raw
  if values.size > 1
    raise 'table should have only one column in this step!'
  else
    values = values.first
  end

  select_box= get_element_from(select_box)
  unless select_box['multiple']
    raise "this is not multiple select box!"
  else
    values.each do |value|
	    patiently { select_box.value.should_not include(value) }
    end
  end
end


#************************ END DROP DOWNS******************************************


#************************ CHECKBOXES *********************************************

#Example: And the "Accept user agrement" checkbox should be checked
Then /^the "([^"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = get_element_from(label)['checked']
    patiently { field_checked.should be_truthy }
  end
end

#Example: And the "Do not touch me" checkbox should not be checked
Then /^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = get_element_from(label)['checked']
    patiently { field_checked.should be_falsey }
  end
end

#Example: And the "Sex" selectbox should contain: Table
Then /^the "(.*?)" selectbox should contain:$/ do |locator, options|
  patiently do
    select_options_for(locator).should == options.raw.join(' ')
  end
end


#************************ END CHECKBOXES *****************************************


#************************ RADIO BUTTONS*******************************************


#Example: And the "radio 1" radio should be selected
Then /^the "(.*?)" radio should be selected$/ do |locator|
  patiently do
    element = get_element_from(locator)
    element.should be_checked
  end
end
#Example: And the "radio 2" radio should not be selected
Then /^the "(.*?)" radio should not be selected$/ do |locator|
  patiently do
    element = get_element_from(locator)
    element.should_not be_checked
  end
end


#************************ END RADIO BUTTONS***************************************


#************************ DATE FIELD *********************************************


#Example: Then "12/31/2013" should be the default date for "datepicker"
Then /^"(.*?)" should be the default date for "(.*?)"$/  do |date_rule, field|
  patiently do 
    date_field = get_element_from(field) 
    date_field.value.should == calculated_date_from(date_rule) 
  end
end


#************************ END DATE FIELD *****************************************



#****************Read from Excel

#****************User Name Field

#Example: Then I enter user name from excel in "Username" 
Then /^I enter user name from excel in "(.*?)"$/ do |locator|
element = get_element_from(locator)

require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
workbook = Spreadsheet.open 'C:\cmsmoketest\features\specifications\SmokeTest\book5.xls'
sheet1 = workbook.worksheet 0
sheet1.each 1 do |row|
	#puts "#{row[0]} - #{row[1]} - #{row[2]}"
	resolt = "#{row[0]}" 
	element.set resolt
end
end


#****************Password Field

#Example: Then I enter user name from excel in "Username" 
Then(/^I enter password from excel in "([^"]*)" field$/) do |locator|
element = get_element_from(locator)
require 'spreadsheet'
Spreadsheet.client_encoding = 'UTF-8'
workbook = Spreadsheet.open 'C:\cmsmoketest\features\specifications\SmokeTest\book5.xls'
sheet1 = workbook.worksheet 0
sheet1.each 1 do |row|
	resolt = "#{row[1]}" 
	element.set resolt
end

end

# Reads a plain text file
Then /[Rr]ead file "(.*?)"$/ do |filepath|
  File.foreach(filepath) { |x| print 'Got ', x }
end