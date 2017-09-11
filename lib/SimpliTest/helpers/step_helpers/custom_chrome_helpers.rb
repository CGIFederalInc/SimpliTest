#The chrome profile loads Selenium Helpers as well. These methods
#override the methods available in Selenium Helpers
module CustomChromeHelpers
  def maximize_window
    page.driver.browser.manage.window.resize_to(MAX_WIDTH,MAX_HEIGHT)
  end
  def keydown_on(element)
    element.native.send_key(:arrow_down)
  end

  def capture_screenshot(filename)
    page.driver.browser.save_screenshot(filename)
  end
end
