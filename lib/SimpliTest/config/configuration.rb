require "yaml"
require 'SimpliTest/config/directory_paths'
# Loads configuration from satelite projects
module SimpliTest
  @config = {
    :support_directory => nil,
    :environments_file => nil,
    :pages_file => nil,
    :selectors_file => nil,
    :settings_file => nil,
    :environments => nil,
    :pages => nil,
    :selectors => nil,
    :settings => nil,
    :environment => nil
  }
  @valid_config_keys = @config.keys

  class << self

    #TODO: Improve the documentation below
=begin
****************************************************************
                Load Order/ Dependencies
****************************************************************

          ********TEST PROJECTS****************
          In Test Projects, first load this file
          Then set any config variables
          Then load the environments file in the @config_dir
          The environments file loads the steps directory
          Steps Directory is self sufficient (no external files need to be loaded)
          **************************************

          ********BIN STUBS*********************
          The gem has one bin stub: SimpliTest 
          This simply executes a method in the Main class with @cli_directory
          The Main class in the cli dir requires @helpers_dir and @tasks_dir
          ***************************************

          ********RAKE TASKS*********************
          Some cli commands execute rake tasks in the @tasks_dir
          @tasks_dir requires @helpers_dir
          ***************************************

*****************************************************************
=end

    def configure(opts={})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
      load_configuration
    end

    def default_path_for(key)
      File.join(@config[:support_directory], 'config', "#{key.to_s}.yml")
    end

    def read_from(path_to_file)
      begin
        YAML::load(IO.read(path_to_file))
      rescue Errno::ENOENT
        alert ("Expected to find #{path_to_file} but did not find it.")
      rescue Psych::SyntaxError
        alert "#{path_to_file} YAML file contains invalid syntax. Please correct it"
      end
    end

    def config
      @config
    end

    def load_configuration
      begin
        @config[:environments] = read_from(@config[:environments_file] || default_path_for(:environments))
        @config[:pages] = read_from(@config[:pages_file] || default_path_for(:pages))
        @config[:selectors] = read_from(@config[:selectors_file] || default_path_for(:selectors))
        @config[:settings] = read_from(@config[:settings_file] || default_path_for(:settings))
        @config[:environment] = ENV['ENVIRONMENT'] || @config[:settings]['DEFAULT_ENVIRONMENT'] || @config[:settings][:environments].values.first
        @valid_config_keys = @config.keys
      rescue Exception => e
        alert "There was a problem reading one of the required configuration files\n" + e.message
      end
    end

    def driver
      ENV['SimpliTest_DRIVER'] || @config[:settings]['DRIVER'] || 'selenium'
    end

    def driver=(name)
      @config[:driver]=name
    end

    def mode
      @config[:settings]['MODE'] || 'REGULAR'
    end

    def screen_size
      ENV['SCREEN_SIZE'] || @config[:settings]['SCREEN_SIZE'] || 'Desktop'
    end

    def wait_for_page_load
      @config[:settings]['WAIT_FOR_PAGE_LOAD'].to_i rescue 0
    end

  end #end self << class all methods below this are instance methods

end
