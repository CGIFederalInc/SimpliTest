module ProjectSetupHelpers

  #*****************************REQUIRES/INCLUDE/EXTEND******************************************
  require 'rbconfig'
  require File.join(File.dirname(__FILE__), 'file.rb')
  require File.join(File.dirname(__FILE__), 'windows_ui.rb') 

  def self.included klass #always include FileHelpers/WindowsUIHelpers with this module
    klass.class_eval do
      include FileHelpers
      include WindowsUIHelpers
    end
  end

  def self.extended klass #always extend FileHelpers/WindowsUIHelpers with this module
    klass.class_eval do
      extend FileHelpers
      extend WindowsUIHelpers
    end
  end

  #**********************************PLATFORM****************************************************

  def windows?
    @windows = RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  end

  #**********************************PROJECT******************************************************


  #TODO: Need a massive fix...some of this stuff isn't even right...
  #We shouldnt just be taking the last features directory in path...this could be a big problem
  def project_path_for(directory)
    project_not_found unless project_exists_in?(directory)
    @project_path = directory if @features_sub_dir_exists
    @project_path = File.expand_path('..', directory) if @is_in_the_same_dir_as_features
    @project_path = last_features_dir_in_path if (@feature_files_exist || @index_of_features_dir_in_path)
    if @project_path
      return @project_path
    else
      project_not_found
    end
  end

  def project_exists_in?(directory)
    # see if current_dir == features
    # see if current_dir.sub_dir.include?(features)
    # see if parent_dir == features
    # see if parent_dir == features/support features/specifications
    # see if parent_dir == features/support/config
    # see if parent_dir == features/support/config/selectors.yml
    # see if sibling_dir == features example: project/documentation and project/features
    @directory ||= directory
    features_sub_dir_exists_in? ||
      is_in_the_same_dir_as_features? ||
      feature_files_exist_in? ||
      is_a_nested_subdirectory_of_features?
  end



  def project_not_found
    alert "Could not find the project. Try running this from the main project directory that has the features directory in it"
    raise "Project Not Found Error"
  end

  def features_sub_dir_exists_in?(directory=@directory)
    @features_sub_dir_exists = has_sub_dir?(directory, 'features')
  end

  def has_sub_dir?(dir, sub_dir)
    file = File.join(dir, sub_dir)
    File.directory? file
  end

  def feature_files_exist_in?(dir=@directory)
    @feature_files_exist = Dir[File.join(dir, '*.feature')].any?
  end

  def is_a_nested_subdirectory_of_features?(directory=@directory)
    @index_of_features_dir_in_path = directories_in_path(directory).rindex('features')
  end

  def last_features_dir_in_path(directory=@directory)
    directories = directories_in_path(directory)
    index = @index_of_features_dir_in_path || is_a_nested_subdirectory_of_features?(directory)
    File.expand_path directories[0,index].join(File::SEPARATOR)
  end

  def directories_in_path(directory=@directory)
    @directories_in_path = directory.split(File::SEPARATOR)
  end

  def feature_dir_for(dir=@directory)
    index = is_a_nested_subdirectory_of_features?(dir)
    raise "Invalid Project. It seems your feature is not part of a proper project" unless index
    directories_in_path(dir)[0,index].join(File::SEPARATOR)
  end

  def is_in_the_same_dir_as_features?(directory=@directory)
    parent = File.expand_path('..', directory)
    @is_in_the_same_dir_as_features = features_sub_dir_exists_in?(parent)
  end

  #*****************************USER ALERTS/CONFIRMATION************************************************

  def alert(message)
    windows? ? user_informed_via_prompt?(message) : puts(message)
  end

  def user_consents?
    question = initialization_message + "\nThis will create new files and folders in the current directory. \nWould you still like to proceed?(Y/n)"
    windows? ? user_consents_via_prompt?(question) : user_consents_via_console?(question)
  end

  def user_consents_via_console?(question)
    STDOUT.puts question
    response = STDIN.gets.strip
    %w[y yes].include?(response.downcase)
  end


  #*****************************TEMPLATES****************************************************

  def get_templates_from(*directories)
    templates = []
    directories.each do |dir|
      templates << templates_in(dir)
    end
    templates = templates.flatten
    templates = templates.select { |f| File.file?(f) } #only select files, ignore directories
    templates
  end


  def relative_path_for(template)
    path = template.gsub("#{@templates_dir}/features", '')
    path = File.join(@features_dir, path)
    path = File.join(Pathname.new(File.expand_path(@features_dir)).parent.to_s, 'cucumber.yml') if template =~ /cucumber.yml/
    path
  end

  def templates_in( directory)
    Dir.glob(File.join(@templates_dir, directory, '**/*'))
  end


  #********************************MESSAGES*************************************************


  def directory_exists_message
    %Q{ You already have a features directory!!
Your features directory may contain settings, configuration, test cases and code that you will lose if you choose to delete this directory.
If you are sure you need a fresh start, please delete the features directory and re run this command.
Don't forget to backup any files you might need in the future before you delete the features directory."}
  end

  def initialization_message
    "Initializing a new SimpliTest Project in #{Dir.pwd} \n"
  end

  def abort_message
    "No modifications were made. SimpliTest Project initialization has been aborted"
  end

  def problem_creating_directories_message
    "There was a problem creating a file or directory required for the new SimpliTest project. This is most likely a file permissions issue. Try running this command as an administrator"
  end

  def success_message
    "You have successfully initialized a new SimpliTest project!! See sample files in the features directory"
  end

  def npp_plugin_generated_message
    "A gherkin.xml file has been placed in the current directory.\n" +
      "Now, within Notepad++ open the User Defined dialogue from the View menu.\n" +
      "Click on import and browse to the generated gherkin.xml file.\n" +
      "If you open a .feature file from Notepad++ now, it should now have some color coding."
  end

  def framework_correctly_installed_message
    "Version: #{SimpliTest::VERSION} is correctly installed! Please read the documentation to get started"
  end

end

