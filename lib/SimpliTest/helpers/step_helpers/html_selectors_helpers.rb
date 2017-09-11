module HtmlSelectorsHelpers
  #TODO: Rewrite without test app for template. The code here effing nuts'...clean this shit
  @selectors_file = 'features/support/config/selectors.yml'

  def pagination_links_for(page_number)
    selector = "input[title='Page #{page_number}']"
    all(:css, selector)
  end

  def pagination_element_for(index)
    lookup = {
      'first' => 'firstButton',
      'last' => 'lastButton',
      'previous' => 'prevButton',
      'next' => 'nextButton'
    }
    selector = "##{lookup[index]}"
    elements = all(:css, selector)
    elements.first if elements
  end

  def select_options_for(locator)
    element = get_element_from(locator)
    get_text_from(element)
  end

  def get_element_from(locator, try_field=true, find_button_or_link=false)
    selector, selector_type = selector_for(locator)
    element = nil
    patiently do
      if selector_type == 'xpath'
        element = page.find(:xpath, selector)
      elsif selector_type == 'css'
        element = page.find(:css, selector)
      elsif try_field
        element = page.find_field(selector)
      elsif find_button_or_link
        raise "Button or Link Not Found"
      else
        element = find(selector)
      end
    end
  end


  def get_button_or_link_from(locator)
    begin
      get_element_from(locator, false, true)
    rescue
      begin
        page.find_link(locator)
      rescue
        page.find_button(locator)
      end
    end
  end

  def selector_for(locator)
    if SimpliTest.config_selectors
      mapping = mapping_for(locator)
      mapping ? selector_from(mapping) : default_selector_for(locator)
    else 
      default_selector_for(locator)
    end
  end

  def mapping_for(selector)
    SimpliTest.config_selectors[unquoted(selector)] || false
  end

  def selector_from(selector)
    selector_type = is_xpath?(selector) ? 'xpath' : (is_css?(selector) ? 'css' : 'other')
    selector = without_identifier(selector)
    return selector, selector_type
  end


  def is_xpath?(locator)
    selector_for(locator)[0].match(/xpath:(.*)/)
  end

  def is_css?(locator)
    selector_for(locator)[0].match(/css:(.*)/)
  end

  def without_identifier(locator)
    if match = (is_xpath?(locator) || is_css?(locator))
      return match[1]
    else
      return locator
    end
  end


  def unquoted(string)
    #string[0] is the first char
    #string[-1,1] is the last char
    is_string_quoted = (string[0] == string[-1, 1]) && (%w[' "].include?(string[0]))
    is_string_quoted ? string.gsub(/^"|"$/, '') : string
  end

  def default_selector_for(locator)
    case locator

    when "the page"
      with_selector_type "html > body"
    when "table's header"
      with_selector_type "table tbody > tr th"
    when /^paragraphs?$/
      with_selector_type  "p"
    when "\"table tr\""
      with_selector_type "table tr"
    when "\"div.some_class\""
      with_selector_type "div.some_class"
    else
      with_selector_type locator
    end
  end

  def with_selector_type(selector, selector_type='other')
    [selector, selector_type]
  end

  def validate_absence_of(text)
    min_wait_time = SimpliTest.config_settings ? SimpliTest.config_settings['MIN_WAIT_TIME'] : 2
    using_wait_time min_wait_time do #because we are validating absence we don't need to wait all 5 seconds?
      begin
        should_not have_link(text)
      rescue RSpec::Expectations::ExpectationNotMetError, Capybara::ExpectationNotMet
        element = get_button_or_link_from(text)
        element.should_not be_visible if element.respond_to?(:visible?)
        ## deprecating the approach below for performance reasons
        ##xpath = potential_hidden_paths_for(text).join('|')
        ##should have_xpath(xpath)
      end
    end
  end

  def selectors_from_section(section)
    SimpliTest.config_selectors[section].values
  end

  #def potential_hidden_paths_for(text) #the different ways developers might choose to hide things in the DOM
  #[
  #"//*[@class='hidden' and contains(.,'#{text}')]",
  #"//*[@class='invisible' and contains(.,'#{text}')]",
  #"//*[@style='display: none;' and contains(.,'#{text}')]"
  #]

  #end

end

World(HtmlSelectorsHelpers)
