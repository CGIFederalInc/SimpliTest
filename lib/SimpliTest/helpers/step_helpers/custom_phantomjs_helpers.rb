module CustomPhantomjsHelpers
  def maximize_window
    page.driver.resize_window(MAX_WIDTH,MAX_HEIGHT)
  end

  def tab_on(element)
    element.native.send_key(:Tab)
  end

  def accept_confirmation
    #TODO: accept confirmation
    raise "NotImplementedError"
  end

  def execute_js(script)
    page.execute_script(script)
  end

  def get_text_from(element)
    element.native.all_text
  end

  def click_element(element)
    begin
      element.click
    rescue Capybara::Poltergeist::MouseEventFailed
      element.trigger('click')
    end
  end

  def key_in(character, element)
    element.native.send_key(character)
  end

  def keydown_on(element)
    key_in('Down', element)
  end

  def capture_screenshot(filename)
    page.save_screenshot(filename)
  end

  def change_window(first_or_last)
    raise "Invalid window name #{first_or_last}. You can only use 'first' or 'last'" unless first_or_last =~ /first|last/
    window_handle = page.driver.browser.window_handles.send(first_or_last.to_sym)
    page.driver.browser.switch_to_window(window_handle)
    wait_for(page.driver.browser.window_handles.size, 1)
  end
end
