module SimpliTest
  def self.gems_installed?(list)
    specs = []
    list.each do |gem|
      dep = Gem::Dependency.new(gem)
      specs << !dep.matching_specs.empty?
    end
    specs.uniq == [true]
  end

  def self.chromedriver_detected?
    installed = `chromedriver --help` rescue false
    installed ? true : false
  end

  def self.env_or_setting(setting_name)
    ENV[setting_name] || SimpliTest.config_settings[setting_name]
  end
end

