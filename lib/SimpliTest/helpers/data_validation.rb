require 'json'
require 'erb'
require 'ostruct'
require 'net/http'
# monkey patching Hash for an intersection method
class Hash
  def &(other)
    reject { |k, v| !(other.include?(k) && other[k] == v) }
  end
end


module SimpliTest
  module DataValidationHelpers
    def validate_service_against(db, service_dir, variables)
      require File.join(service_dir, 'mapper')
      #TODO: Horrible hard coding temporarily...will fix later
      SimpliTest.configure( {:support_directory => File.join(@project_path, 'features', 'support')})
      @service_dir = service_dir
      query_results = get_data_from_db(db, variables)
      if defined?(map_service_results)
        service_results = map_service_results(get_data_from_service(variables))
        query_results.each_with_index do |result, index|
          if result & service_results[index] == service_results[index]
            puts "Passed"
          else
            raise "Test Failed for #{service_results[index]}"
          end
        end
      else
        raise "It seems you have not defined a mapper for this service yet!"
      end
    end

    def get_data_from_db(db, variables)
      query = preprocess_template('query.sql', variables)
      db.execute query
    end

    def get_data_from_service(variables)
      service = YAML.load(preprocess_template('service.yml', variables))
      service_path = service['url']
      uri = service_url_for service_path
      JSON.parse Net::HTTP.get(uri)
    end

    def preprocess_template(file, variables)
      template = File.read(File.join(@service_dir, file))
      ERB.new(template).result(OpenStruct.new(variables).instance_eval { binding })
    end

    def service_url_for(path)
      uri = URI.parse(path)
      service_host = SimpliTest.config[:environments][SimpliTest.config_environment + "_Services"]
      service_host = SimpliTest.config[:environments][SimpliTest.config_environment] unless service_host
      uri.absolute? ? uri : URI.parse(service_host + path)
    end

  end
end
