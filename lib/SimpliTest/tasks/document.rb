
=begin
##########Background###############
This file adds a rake task to generate documentation for the Step Definitions available
in this gem
It basically reads each file in the web steps folder, looks for a step definition pattern and parses them
into three columns:
Step(Regex): The regular expression used by the Step Definition
Example step in plain language: Exactly as you would use in your feature files
Arguments the step definition accepts

################Usage:###############
To print this on a Mac or a Linux system with the hirb gem installed: 'gem install hirb'
simply type
rake document

On lesser systems :) (and of course of Mac and Linux too), generate a csv with:
rake document[csv]

ZSH(and some other shell) users, escape the argument with:
rake document\[csv\]
=end

desc 'List all defined steps'
task :document, :format do |t, args|
  format = args[:format]
  initialize_variables
  if format == 'csv'
    @csv = true
    require 'csv'
    CSV.open('step_definitions.csv', 'w') do |csv|
      csv << @columns
      generate_steps_document(csv)
    end
    alert "SUCCESS::Documentation generated in step_definitions.csv"
  elsif format == 'html'
    @html = true
    initialize_html_variables
    @html_content = @html_content.gsub('@header_row', generate_table_row_from(@columns, true))
    generate_steps_document
    FileUtils.cp(@html_document, @new_project_documentation_dir)
    alert "SUCCESS::Documentation generated in step_definitions.html"
  else
    if hirb_installed?
      require 'hirb'
      extend Hirb::Console
      generate_steps_document
    else
      puts "Please either pass a format identifier like 'document[html] document[csv] or gem install hirb for console output'"
    end
  end
end

def initialize_variables
  #@potential_step = /^\s*(?:Given|When|Then|And)\s+|\//
  @gem_dir = SimpliTest.path_to_gem_dir
  @step_regex =  /(?:Given|When|Then|And)[\s\(]*\/(.*)\/([imxo]*)[\s\)]*do\s*(?:$|\|(.*)\|)/
  @step_definition_dir = SimpliTest.path_to_steps_dir
  @example_regex = /#Example:(.*)/
  @columns = [:category, :step, :example, :arguments]
end

def initialize_html_variables
  @templates_dir = SimpliTest.path_to_templates_dir
  @new_project_documentation_dir = File.join(@templates_dir, 'NewSimpliTestProject', 'documentation')
  @html_template = File.join(@templates_dir, "document/index.html")
  @html_dir = File.join(@templates_dir, "document")
  @html_content = File.join(@gem_dir, File.read(@html_template))
  @css_file = File.join(@templates_dir, "document/css/style.css")
  @html_document = "step_definitions.html"
  @table_body = ''
end

def generate_steps_document(csv=nil)
  print_heading_on_console
  Dir.glob(File.join(@step_definition_dir,'*.rb')).each do |step_file|
    print_file_name_for(step_file, csv)
    results = []
    File.new(step_file).read.each_line.each_cons(3) do |previous_line, line, next_line|
      #next unless line =~ @potential_step
      step_match = @step_regex.match(line)
      next unless step_match
      example_match = @example_regex.match(previous_line)
      example = example_match ? example_match[1] : 'N/A'
      matches = step_match.captures
      results << capture_row_with(matches, example, csv, @category)
    end
    print_on_console(results)
    generate_html_document if @html
  end
end


def print_heading_on_console
  return if @csv || @html
  puts "CUCUMBER steps:"
  puts ""
end

def print_file_name_for(step_file, csv)
  @category = category_from(step_file)
  if csv
  elsif @html
  else
    puts "Category: #{@category}"
    puts ""
  end
end

def print_on_console(results)
  return if @csv || @html
  table results, :resize => false, :fields => [:step, :example, :arguments]
  puts ""
  puts ""
end

def capture_row_with(matches, example, csv, file_name)
  step_elements = value_of([file_name, matches[0], example,  matches[2]])
  if csv
    csv << step_elements
  elsif @html
    @table_body << generate_table_row_from(step_elements)
  else
    OpenStruct.new(
      :step => value_of(matches[0]),
      :example => value_of(example),
      :arguments => value_of(matches[2])
    )
  end
end

def generate_table_row_from(array, header=false)
  tag = header ? 'th' : 'td'
  row = array.map{|x| "<#{tag}>#{x}</#{tag}>"}.join
  "<tr>#{row}</tr>"
end

def generate_html_document
  content = @html_content.gsub('@table_body', @table_body)
  content_with_responsive_label = content.gsub('@responsive_label', responsive_labels_for(@columns))
  css = File.read(@css_file)
  content_with_css = content_with_responsive_label.gsub('@css', css)
  content_with_version_number = content_with_css.gsub('@version', SimpliTest::VERSION)
  document = File.open(@html_document, "w") {|file| file.write(content_with_version_number)}
end

def responsive_labels_for(array)
  label = ''
  array.each_with_index.collect do |header, index|
    label << "td:nth-of-type(#{index+1}):before { content: '#{header}'; }"
  end
  label
end

def value_of(value)
  return value.map {|member| value_of(member) } if value.is_a?(Array)
  (value.nil? || value.empty?) ? 'N/A' : value
end

def category_from(file_name)
  File.basename(file_name).gsub(/\.rb/,'').gsub(/_/,' ').gsub(/steps/,'')
end

def hirb_installed?
  dep = Gem::Dependency.new('hirb')
  hirb = dep.matching_specs
  !hirb.empty?
end

