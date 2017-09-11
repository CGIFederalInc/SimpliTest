include ProjectSetupHelpers
desc "Returns a message if the gem is installed"
task :testinstall do
  alert framework_correctly_installed_message
end
