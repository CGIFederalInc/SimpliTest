require 'SimpliTest'
require 'SimpliTest/config/directory_paths'
require 'SimpliTest/helpers/project_setup'
require 'SimpliTest/helpers/data_validation'
#TODO: Clean this up with OptionsParser
module SimpliTest
  module Cli
    ## Command Line Interface to the SimpliTest Suite
    class Main
      extend ProjectSetupHelpers
      class << self
        def execute(args)
          new(args).execute!
        end

        def new(opts={})
          initialize(opts)
        end

        def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
          opts, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
          @command = opts[:command].respond_to?(:downcase) ? opts[:command].downcase : opts[:command]
          @arguments = opts[:arguments]
          @arguments = @arguments.reject{|arg| (arg.to_s.empty? rescue true) } unless @arguments.is_a?(Array)
          @pwd = opts[:pwd]
          @gem_dir = opts[:gem_dir]
          @environment = ENV['ENVIRONMENT']
          @valid_commands = %w[create_update_task
                               document
                               document[csv]
                               document[html]
                               focustest
                               generate_npp_plugin
                               generate_registries
                               help
                               init
                               new
                               parallel
                               run
                               run_feature
                               sauce
                               setup
                               smoketest
                               testinstall
                               testproject
                               update
                               validate_service
                               -v
                               version
          ]
          self
        end

        def execute!
          case @command
          when 'create_update_task'
            create_update_task
          when 'generate_npp_plugin'
            generate_npp_plugin
          when 'generate_registries'
            generate_registries
          when 'help'
            puts help_text
          when 'init'
            initialize_project_in
          when 'new'
            create_new_project
          when 'parallel'
             run_in_parallel
          when 'run'
            run_as_cucumber
          when 'run_feature'
            run_feature
          when 'setup'
            setup_SimpliTest
          when 'smoketest'
            perform_smoke_test
          when 'testinstall'
            run_as_rake
          when 'testproject'
            testproject
          when 'update'
            `gem update SimpliTest`
          when 'validate_service'
            validate_service
          when '-v', 'version'
            puts "SimpliTest: v#{SimpliTest::VERSION}"
          when '',nil
            alert(framework_correctly_installed_message)
          else
            if @valid_commands.include?(@command)
              alert "This feature has been deprecated. Please see the documentation folder in your project for help"
            else
              alert "You entered an invalid command"
            end
            @kernel.exit(0)
          end
        end
=begin
*********************************************-------------------****************************************************************************
********************************************| CUCUMBER COMMANDS |***************************************************************************
*********************************************-------------------****************************************************************************
=end


        def run_as_cucumber(args = @arguments.dup, verify_file_exists=false)
          if verify_file_exists
            unless File.exists? args.first
              alert "#{args.first} File was Not Found. Could not run tests"
              raise "FileNotFoundError"
            end
          end
          @project_path ||= project_path_for(@pwd)
          runtime = prepare_runtime
          run_dir = @project_path
          Dir.chdir(run_dir)
          Cucumber::Cli::Main.new(args).execute!(runtime)
        end

        def run_in_parallel
          raise "Parallelization is not supported on Windows" if windows?
          begin
            `parallel_cucumber features`
          rescue Exception => e
            message = "There was a problem running tests in parallel"
            alert message
            puts e.message
          end
        end

        def prepare_runtime
          require 'cucumber'
          runtime = Cucumber::Runtime.new
          runtime.load_programming_language('rb')
          runtime
        end

        def perform_smoke_test
          @project_path ||= project_path_for(@pwd)
          smoke_test = File.join(@project_path, 'features', 'specifications', 'SmokeTest')
          run_as_cucumber([smoke_test], true)
        end

        def perform_focus_test
          focus_path = File.join(project_path_for(@pwd), 'features', 'specifications', 'Focus')
          run_as_cucumber([focus_path], true)
        end

        def testproject
          #TODO: Write a utility that verifies project configuration. See list below:
          #YAML errors in config files
          #Missing Files
          #Access to Gem Step definitions
          #Basically anything the user can break by changing something in the test project
          @project_path ||= project_path_for(@pwd)
          Dir.chdir @project_path
          begin
            `cucumber --dry-run`
            alert('Finished checking the project. If you do not see any errors on the command prompt..you are good to go')
          rescue Exception => e
            message = "It seems that your project directory is corrupted \n It maybe possible for you to simply generate a new project and copy your test cases over. "
            alert(message)
            puts e.message
          end

        end

        def run_feature
          feature = @arguments.first
          feature = File.exists?(feature) ? feature : File.join(project_path_for(@pwd), 'features', 'specifications', feature)
          run_as_cucumber([feature], true)
        end
=begin
*********************************************-------------------****************************************************************************
********************************************| CUCUMBER COMMANDS |***************************************************************************
*********************************************-------------------****************************************************************************
=end

=begin
*********************************************-------------------****************************************************************************
********************************************|    PROJECT SETUP  |***************************************************************************
*********************************************-------------------****************************************************************************
=end

        ## Invoked with SimpliTest new <project name>
        ## Creates a new example project with the <project name> with sample test cases and documentation
        def create_new_project
          if user_consents?
            unless project_exists_in?(@pwd)
              new_dir_name = @arguments.join(' ')
              new_dir_path = (File.join(@pwd, new_dir_name))
              make_directory(new_dir_path)
              initialize_project_in(new_dir_path, true)
            else
              alert "You cant create a project inside an existing project!"
            end
          else
            alert abort_message
          end
        end
        ## Invoked inside a directory with SimpliTest init
        ## Creates a new SimpliTest project within the current directory
        # @param target_directory
        # @param user_has_consented (true if user types or clicks yes)
        def initialize_project_in(target_directory=@pwd, user_has_consented=false)
          if (user_has_consented|| user_consents?)
            if (project_exists_in?(target_directory))
              alert directory_exists_message
            else
              project_template_dir = template_path_to 'NewSimpliTestProject'
              FileUtils.cp_r(Dir[File.join(project_template_dir, '*')], target_directory)
              alert("Successfully Initialized Project!")
            end
          else
            alert abort_message
          end
        end

=begin
*********************************************-------------------****************************************************************************
********************************************|    PROJECT SETUP  |***************************************************************************
*********************************************-------------------****************************************************************************
=end



=begin
*********************************************-------------------****************************************************************************
********************************************|  DATA VALIDATION  |***************************************************************************
*********************************************-------------------****************************************************************************
=end

        def validate_service
          args = @arguments.dup
          load_db_options
          if args.empty?
            validate_all_services
          else
            args.each do |service_name|
              validate_service_by_name(service_name)
            end
          end
        end

        def load_db_options
          require 'tiny_tds'
          require 'csv'
          extend DataValidationHelpers
          @project_path ||= project_path_for(@pwd)
          database_config = File.join(@project_path, 'features', 'support', 'config', 'database.yml')
          options = YAML.load(File.read(database_config))
          @db = TinyTds::Client.new(options)
        end

        def validate_all_services
          services_dir_glob_pattern = File.join(@project_path, 'data', '*', File::SEPARATOR)
          services = Dir.glob(services_dir_glob_pattern).collect{|k| k.split(File::SEPARATOR).last}
          services.each do |service|
            puts "Running Test for: #{service}"
            validate_service_by_name service
          end
        end

        def validate_service_by_name(name)
          service_config_dir = File.join(@project_path, 'data', name)
          variables_file = File.join(service_config_dir, 'variables.csv')
          variables_csv = CSV.read(variables_file, :headers => true)
          variables_hash = variables_csv.reject{|r| r.empty?}.map {|r| r.to_hash }
          variables_hash.each do |set|
            validate_service_against(@db, service_config_dir, set)
          end
        end

=begin
*********************************************-------------------****************************************************************************
********************************************|  DATA VALIDATION  |***************************************************************************
*********************************************-------------------****************************************************************************
=end





        def run_as_rake(from_dir=@pwd)
          require 'rake'
          require 'pp'
          Dir.chdir(@gem_dir) # We'll load rakefile from the gem's dir.
          Rake.application.init
          Rake.application.load_rakefile
          Dir.chdir(from_dir)
          Rake.application.invoke_task(@command)
        end

        def help_text
          #TODO: Write a man page
          'You have been helped!!'
        end


      end #end self << class. Any methods below this are instance methods
    end#end Main
  end#end Cli
end#end SimpliTest


