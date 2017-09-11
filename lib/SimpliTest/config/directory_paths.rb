require 'yaml'
require 'pathname'
require 'SimpliTest/helpers/project_setup'
# exports instance variables for various directories of interest in the gem and the satelite projects
module SimpliTest
  extend ProjectSetupHelpers
  @config_dir = File.dirname(__FILE__)
  @SimpliTest_dir = Pathname.new( @config_dir).parent.to_s
  @helpers_dir = File.join(@SimpliTest_dir, 'helpers')
  @steps_dir = File.join(@SimpliTest_dir, 'steps')
  @step_helpers_dir = File.join(@helpers_dir, 'step_helpers')
  @templates_dir = File.join(@SimpliTest_dir, 'templates')
  @lib_dir = Pathname.new(@SimpliTest_dir).parent.to_s
  @tasks_dir = File.join(@SimpliTest_dir, 'tasks')
  @gem_dir = Pathname.new(@lib_dir).parent.to_s
  class << self
    #TODO: Using method missing despite all the reasons not to
    #FIXME: Get rid of this
    def method_missing(meth, *args, &block)
      if match = meth.to_s.match(/^config_(.+)$/)
        config[match[1].to_sym]
      elsif match = meth.to_s.match(/^path_to_(.+)$/)
        instance_variable_get("@#{match[1]}")
      else
        super # You *must* call super if you don't handle the
        # method, otherwise you'll mess up Ruby's method
        # lookup.
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?('config_') || meth.to_s.start_with?('path_to_') || super
    end
  end

end
