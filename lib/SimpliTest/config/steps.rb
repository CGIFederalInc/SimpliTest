require 'uri'
require 'cgi'
load_directories =  [File.join(SimpliTest.path_to_steps_dir, '*.rb'), File.join(SimpliTest.path_to_step_helpers_dir, '*.rb')]
load_directories.each do |dir|
  Dir[dir].each {|file| require file }
end


