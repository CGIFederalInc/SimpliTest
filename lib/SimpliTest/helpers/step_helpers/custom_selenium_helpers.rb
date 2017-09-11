module CustomSeleniumHelpers
  def maximize_window
    page.driver.browser.manage.window.resize_to(MAX_WIDTH, MAX_HEIGHT)
  end

  def capture_screenshot(filename)
    page.driver.browser.save_screenshot(filename)
  end

  def accept_confirmation
    page.driver.browser.switch_to.alert.accept
  end

  def execute_js(script)
    page.driver.browser.execute_script(script)
  end

  def get_text_from(element)
    element.text
  end

  def click_element(element)
    element.click
  end

  def key_in(character, element)
    element.native.send_key(character)
  end

  def keydown_on(element)
    key_in(:arrow_down, element)
  end

  def change_window(first_or_last)
    raise "Invalid window name #{first_or_last}. You can only use 'first' or 'last'" unless first_or_last =~ /first|last/
    window_handle = page.driver.browser.window_handles.send(first_or_last.to_sym)
    page.driver.browser.switch_to.window(window_handle)
    wait_for(page.driver.browser.window_handles.size, 1)
  end
end

