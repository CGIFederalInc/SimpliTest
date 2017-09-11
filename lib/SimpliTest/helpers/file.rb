module FileHelpers
  require 'fileutils'

  def make_directory(dirname)
    FileUtils.mkdir_p(dirname)
  end

  def copy_file(source, target)
    FileUtils.cp(source, target)
  end

  def copy_folder(source, target)
    FileUtils.copy_entry(source, target)
  end

  def make_subdirectories_in(directory, *subdirectories)
    subdirectories.each do |subdir|
      FileUtils.mkdir_p(File.join(directory, subdir))
    end
  end

  def template_path_to(*args)
    relative_path = args.join(File::Separator)
    File.join(SimpliTest.path_to_templates_dir, relative_path)
  end

  def copy_file_with_replacement_args(template_name, target_location, args={})
    file = File.open(template_path_to(template_name))
    content = file.read
    target_location = File.join(@pwd, template_name) unless target_location
    args.each do |key, value|
      content = content.gsub(/#{key}/,value )
    end
    File.open(target_location, 'w') { |f| f.write(content) }
  end


end
