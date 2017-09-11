
desktop_max_height = SimpliTest.config[:settings]["DESKTOP_MAX_HEIGHT"] || 980
desktop_max_width = SimpliTest.config[:settings]["DESKTOP_MAX_WIDTH"] || 1045
mobile_max_height = SimpliTest.config[:settings]["MOBILE_MAX_HEIGHT"] || 868
mobile_max_width = SimpliTest.config[:settings]["MOBILE_MAX_WIDTH"] || 362
tablet_max_height= SimpliTest.config[:settings]["TABLET_MAX_HEIGHT"] || 868
tablet_max_width = SimpliTest.config[:settings]["TABLET_MAX_WIDTH"] || 814
landscape_max_height = SimpliTest.config[:settings]["LANDSCAPE_MAX_HEIGHT"] || 362
landscape_max_width = SimpliTest.config[:settings]["LANDSCAPE_MAX_WIDTH"] || 522


case SimpliTest.screen_size
when "Mobile"
  MAX_HEIGHT = mobile_max_height
  MAX_WIDTH =  mobile_max_width
when "Tablet"
  MAX_HEIGHT = tablet_max_height
  MAX_WIDTH =  tablet_max_width
when "Desktop"
  MAX_HEIGHT = desktop_max_height
  MAX_WIDTH =  desktop_max_width
when "Landscape"
  MAX_HEIGHT = landscape_max_height
  MAX_WIDTH =  landscape_max_width
end
