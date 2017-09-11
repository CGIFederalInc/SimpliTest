=begin
*******************************************************************
This file sets some very important configuration settings for the framework
DO NOT DELETE THIS FILE
Some options are configurable, but changing this file is not recommended
It might cause all your tests to fail!!
Unless you know what you are doing :)
The defaults are shown below, you can customize any of these:
  configuration = {
                   :support_directory => 'path_to_your_project/features/support',
                   :environments_file => 'path_to_your_project/features/support/config/environments.yml',
                   :environments => {},
                   :environment => '',
                   :settings_file => 'path_to_your_project/features/support/config/settings.yml',
                   :settings => {},
                   :pages_file => 'path_to_your_project/features/support/config/pages.yml',
                   :pages => {},
                   :selectors_file => 'path_to_your_project/features/support/config/selectors.yml',
                   :selectors => {},

  }
You only need to specify a file or a hash for each property. For example, you can specify either a 
YAML file with a mapping of all paths to be used in your test suite or simply pass those paths as a hash here. 

IMPORTANT: configuration must be loaded before requiring SimpliTest/steps or this will not work!!
********************************************************************
=end

require 'SimpliTest'
SimpliTest.configure( {:support_directory => File.dirname(__FILE__)})
require 'SimpliTest/config/environment'


