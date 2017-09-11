
#************************ NAVIGATION *********************************************

#Example: Then  I should be redirected to the "congratulations" page
Then /^I should be redirected to the "(.*)" page$/ do |page_name|
  definition = <<-def
I should be on the "#{page_name}" page
  def
  step definition
end

#Example: Then I should be redirected to the "Results" page with some parameters
Then(/^I should be redirected to the "(.*?)" page with some parameters$/) do |page_name|
  sleep SimpliTest.wait_for_page_load
  target_url = without_trailing_slash(path_to(page_name)).downcase
  patiently do
    current_url = without_trailing_slash page.current_url.downcase
    if current_url.index(target_url)
      current_url.index(target_url).should_not be_nil
    else
      current_url.should == target_url
    end
  end
end

#Example: Then  I should be on the "congratulations" page
Then /^(?:|I )should be on the "(.*)" page$/ do |page_name|
  sleep SimpliTest.wait_for_page_load
  target_url, current_url = comparable_urls_for(path_to(page_name), page.current_url)
  current_url.should == target_url
end


#************************ END NAVIGATION *****************************************


#************************ LABELS AND TEXT ****************************************


#Example: And I should see "Great, you can click links!"
Then /^(?:|I )should see "(.*)"$/ do |text|
  patiently { page.should have_content(text) }
end


#Example: And I should not see "some bla-bla"
Then /^(?:|I )should not see "(.*)"$/ do |text|
  patiently { page.should have_no_content(text) }
end

#Example: Then I should see /great/i
Then /^(?:|I )should see \/([^\/]*)\/([imxo])?$/ do |regexp,flags|
  regexp_opts = [regexp,flags].compact
  regexp = Regexp.new(*regexp_opts)
  patiently { page.should have_xpath('//*', :text => regexp) }
end

#Example: Then I should not see /bla-bla/i
Then /^(?:|I )should not see \/([^\/]*)\/([imxo])?$/ do |regexp,flags|
  regexp_opts = [regexp,flags].compact
  regexp = Regexp.new(*regexp_opts)
  patiently { page.should have_no_xpath('//*', :text => regexp) }
end

#Example: Then I should see all of the texts: <pass a table with text values>
Then /^I should see all of the texts:?$/ do |table|
  table.raw.each do |text|
    step "I should see \"#{text[0]}\""
  end
end

#TODO: No test case for this
#TODO: This step is redundant, deprecate it
#Example: Then I should see the "ZipInlineFeedback" text as "Hello"
#Example: Not yet implemented
Then /^I should see the "(.*?)" text as "(.*)"$/ do |locator, text|
  patiently do
    element = get_element_from(locator, false)
    element.text.should == text
  end
end


#************************ END LABELS AND TEXT ************************************


#************************ BUTTONS AND LINKS **************************************

#Example: Then I should see the "Submit" button
Then /^(?: |I )should see the "(.*)"(?: button| link)$/ do |link_or_button_text|
  patiently do
  selector, selector_type = selector_for(link_or_button_text)
  if selector_type == 'other'
    begin
      should have_link(link_or_button_text)
    rescue RSpec::Expectations::ExpectationNotMetError
      should have_button(link_or_button_text)
    end
  else
    find(selector_type.to_sym, selector)
  end
  end
end


#TODO: the double patiently block makes me sad
#Example: And I should not see the "Click Me" link
Then /^(?: |I )should not see the "(.*)"(?: button| link)$/ do |button_or_link_text|
  validate_absence_of button_or_link_text
end

#Example: Then I should see a link that points to "http://www.google.com/"
Then /^I should see an? link that points to "([^"]*)"$/ do |href_destination|
  page.should have_xpath("//a[@href='#{href_destination}']")
end

#Example: Then the 5th instance of "Page1PaginationLinks" should be disabled
Then /^the (first|last|[0-9]+(?:th|st|rd|nd)) instance of "(.*?)" should be disabled$/ do |index, button_or_link|
  selector, selector_type = selector_for(button_or_link)
  index = numerize index
  if selector_type == 'css'
    elements = all(:css, selector)
  else
    raise "Only CSS Selectors are supported. Please add a Valid CSS Selector in selectors.yml"
  end
  elements[index].should be_disabled if elements
end

#Example: Then I should see that all asset references on the page are valid
Then /^I should see that all asset references on the page are valid$/ do
   patiently do
     document = parse_dom_tree(current_url)
     valid_assets_links_from(document).each do |link|
       validate_response_from(current_url, link)
     end
   end
end

#Example: And I should see that all links on the page are valid
Then /^I should see that all links on the page are valid$/ do
  document = parse_dom_tree(current_url)
  links_on(document).each do |link|
    validate_response_from(current_url, link)
  end
end


#************************ BUTTONS AND LINKS **************************************

#************************ PAGINATION **************************************

#Example: Then I should be on page 2
Then /^I should be on page (\d+)$/ do |page_number|
  pagination_links_for(page_number).collect(&:disabled?).uniq.should == [true]
end

#************************ PAGINATION **************************************



#************************ LIST/ ERROR MESSAGES ***********************************

#TODO: Add a test
#Example: Then I should see the following errors: Accepts Gherkin Table
#Example: Not yet implemented
Then /^I should see the following(?: errors| list):$/ do |table|
  column_header, *list = table.raw
  list.flatten.each do |message|
    patiently { page.should have_content(message) }
  end
end


#************************ END LIST/ ERROR MESSAGES *******************************


#************************ TAGS ***************************************************

#Example: Then I should see a "td" tag around "bla"
Then /^I should see an? "([^"]*)" tag around the text "([^"]*)"$/ do |tag_name, text|
  page.should have_xpath("//#{tag_name}[text()=\"#{text}\"]")
end

#Example: Then I should see a "div" with "id" of "ui-datepicker-div"
Then /^I should see an? "([^"]*)" with "([^"]*)" of "([^"]*)"$/ do |tag_name, attribute_name, attribute_value|
  page.should have_xpath("//#{tag_name}[@#{attribute_name}=\"#{attribute_value}\"]")
end


#************************ END TAGS ***********************************************


#************************ IMAGES *************************************************

#TODO: Add Examples
#Example: Then I should see the image "Image1.jpg"
Then /^I should see the image "([^"]*)"$/ do |image_name|
  page.should have_xpath("//img[contains(@src, \"#{image_name}\")]")
end

#Example: Then I should see all of the images: <accepts a list of image names(src)>
Then /^I should see all of the images:?$/ do |table|
  table.raw.each do |text|
    step "I should see the image \"#{text[0]}\""
  end
end

#Example: Then I should see text "some alt text" as alt text for ImageSelector
Then /^(?:|I )should see text  "(.*)" as alt text for (.*)$/ do |alt_text, locator|
  selector, selector_type = selector_for(locator)
  if selector_type == 'xpath'
    patiently { page.should have_xpath("#{selector}[@alt='#{alt_text}']") }
  elsif selector_type == 'css'
    patiently { page.should have_css("#{selector}[alt='#{alt_text}']") }
  else
    patiently { page.should have_xpath("//img[contains(@src, '#{unquoted(selector)}')][@alt='#{alt_text}']") }
  end
end


#************************ END IMAGES *********************************************


#************************ AUDIO **************************************************

#TODO: Add Examples
#Example: Then I should see the HTML5 audio source "Audio.mp3"
Then /^I should see the HTML5 audio source "([^"]*)"$/ do |audio_name|
  page.should have_xpath("//audio[contains(@src, \"#{audio_name}\")] | //audio/source[contains(@src, \"#{audio_name}\")]")
end
#Example: Then I should see the HTML5 audio sources: <Accepts a list of audio file names>
Then /^I should see all of the HTML5 audio sources:?$/ do |table|
  table.raw.each do |text|
    step "I should see the HTML5 audio source \"#{text[0]}\""
  end
end


#************************ END AUDIO **********************************************


#************************ VIDEO **************************************************

#TODO: Add Examples
#Example: Then I should see the HTML5 video source "video1.mp4"
Then /^I should see the HTML5 video source "([^"]*)"$/ do |video_name|
  page.should have_xpath("//video[contains(@src, \"#{video_name}\")] | //video/source[contains(@src, \"#{video_name}\")]")
end

#Example: Then I should see the HTML5 video sources: <accepts a table of video sources>
Then /^I should see all of the HTML5 video sources:$/ do |table|
  table.raw.each do |text|
    step "I should see the HTML5 video source \"#{text[0]}\""
  end
end


#************************ VIDEO **************************************************


#************************ OTHER ELEMENTS *****************************************


#TODO: Hate the language here, need to fix this
#Example: Then  I should see 2 elements kind of table's header
Then /^I should see (\d+) elements? kind of (.+)$/ do |count, locator|
  selector, xpath = selector_for(locator)
  patiently do
    actual_count = all(selector).count
    count = count.to_i
    actual_count.should eq(count)
  end
end

#Example: And I should not see elements kind of paragraphs
Then /^I should not see elements? kind of (.+)$/ do |locator|
  patiently {  page.should_not have_css(selector_for(locator).first) }
end


#************************ END OTHER ELEMENTS *************************************



#Example: Not Implemented yet
Then /^I should see "(.*?)" as "(.*?)" value$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end


#*********************** SELECTOR SECTION ********************************


#Example: Then I should see the correct "MedicareGovHeader"
Then /^I should see the correct "(.*)"$/ do |section|
  locators = selectors_from_section(section)
  locators.each do |locator|
    if is_css?(locator)
      should have_css(selector_from(locator).first)
    elsif is_xpath?(locator)
      should have_xpath(selector_from(locator).first)
    else
      raise "Could not determine selector type for #{selector}"
    end
  end
end
