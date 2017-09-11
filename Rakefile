module TempFixForRakeLastComment
  def last_comment
    last_description
  end 
end
Rake::Application.send :include, TempFixForRakeLastComment

require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'SimpliTest/config/directory_paths'
require 'SimpliTest/config/local_environment'
require 'SimpliTest'
Dir["#{SimpliTest.path_to_helpers_dir}/*.rb"].each {|file| require file }
Dir["#{SimpliTest.path_to_tasks_dir}/*.rb"].each {|file| require file }

dev_gems = %w[rake-notes bundler]
if SimpliTest.gems_installed?(dev_gems)
  require 'rake/notes/rake_task'
  require 'bundler'
  require 'bundler/gem_tasks'
  Bundler::GemHelper.install_tasks
end

RSpec::Core::RakeTask.new
Cucumber::Rake::Task.new


