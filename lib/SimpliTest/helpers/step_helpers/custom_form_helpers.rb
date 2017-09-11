module CustomFormHelpers

  def numerize(number_name)
    case number_name
    when 'first'; 0
    when 'last'; -1
    else number_name.match(/[0-9]/)[1].to_i + 1 rescue 0 #take the first one if you cant figure it out
    end
  end

  def blur(selector_and_xpath)
    css_selector, xpath = selector_and_xpath
    selector = xpath ? xpath : css_selector
    if xpath
      return
    else
      #TODO: Hate how this done...need to come back to this
     execute_script_for_driver(SimpliTest.config_driver, %Q{ $('#{selector}').blur(); })
    end
  end

  def fill_in_masked_field(css_selector, value)
    STDOUT.puts "Entering #{value} in Masked Field #{css_selector} now" #TODO: Delete this debugging statement
    execute_script_for_driver(SimpliTest.config_driver, %Q{ $("#{css_selector}").val("#{value}"); })
    STDOUT.puts "Blurring the field now" #TODO: Delete this debugging statement
    execute_script_for_driver(SimpliTest.config_driver, %Q{ $("#{css_selector}").blur(); })
    #page.driver.debug
  end


  def press_key(key)
    keycode = keycode_for[key.downcase.gsub(' ','_')]
    keypress_script = "var e = $.Event('keydown', { keyCode: #{keycode} }); $('body').trigger(e);"
    execute_js(keypress_script)
  end

  def tab_on(element)
    element.native.send_key(:tab)
  end

  def keypress_on(elem, key, charCode = 0)
    keyCode = keycode_for[key]
    elem.base.invoke('keypress', false, false, false, false, keyCode, charCode);
  end

  def keycode_for
    {
      :tab => 9,
      :enter => 13,
      :up_arrow => 38,
      :down_arrow => 40,
      :left_arrow => 37,
      :right_arrow => 39,
      :escape => 27,
      :spacebar => 32,
      :ctrl => 17,
      :alt => 18,
      :shift => 16,
      :caps_lock => 20,
      :backspace => 8,
      :delete => 46
    }
  end
end
World(CustomFormHelpers)

