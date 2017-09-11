module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  #TODO: Rewrite without test app for template
  def path_to(page_name)
    if is_url?(page_name)
      page_name
    elsif SimpliTest.config_pages
      matches = SimpliTest.config_pages.select { |p| unquoted(page_name) == p }
      matches.any? ? url_from(matches, page_name) : default_path_for(page_name)
    else
      default_path_for(page_name)
    end
  end
# :nocov:
  def url_from(matches, page_name)
    if matches.length > 1
      raise "Oops ambigous page name! More than one matched our search. It seems you have similar page names. \n" +
        "Now, go and modify #{page_name} to something cooler in config/pages.yml"
    else
      path = matches.values.first
    end
    url_to(path) if path
  end

  def default_path_for(page_name)
    case page_name

    when /^home$/
      '/'
    when /^congratulations$/
      '/congratulations'
    when /^other$/
      '/other/page'
    when /^form$/
      '/form/page'
    when /^valid_links$/
      '/valid-links'
    when /^invalid_links$/
      '/invalid-links'
      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
# :nocov:

  def url_to(path)
    if is_url?(path)
      path
    else
      begin
        URI.parse(SimpliTest.config_environments[SimpliTest.config_environment] + path).normalize.to_s
      rescue
        puts "It seems that the #{SimpliTest.config_environment} enviroment has not been set up. Please add it to features/config/environments.yml"
        raise "Unidentified Environment Requested!!"
      end
    end
  end

  def is_url?(path)
    uri = URI.parse(path)
    uri if uri.scheme =~ /^https?$/
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  def is_relative?(path)
    uri = URI.parse(path)
    uri.relative?
  end

  def is_valid_url_or_path?(path)
    is_url?(path) || is_relative?(path)
  end

  def is_javascript_href?(href)
    href =~ /^(javascript|#)/
  end

  def parse_dom_tree(url)
    Nokogiri::HTML(open(url))
  end

  def valid_assets_links_from(nokogiri_html_document)
    doc = nokogiri_html_document
    links = stylesheet_references_on(doc) + javascript_references_on(doc)
    links.select{ |l| !is_javascript_href?(l) }
  end

  def stylesheet_references_on(doc)
    doc.css('link').collect{|l| l['href'] }.compact
  end

  def javascript_references_on(doc)
    doc.css('script').collect{|l| l['src']}.compact
  end

  def links_on(doc)
    doc.css('a').collect{|l| l['href']}.compact.select{ |l| !is_javascript_href?(l) }
  end

  def validate_response_from(page_name, href)
    begin
      root_path = path_to(page_name)
      uri = is_relative?(href) ? (URI.join(root_path, href)) : URI.parse(href)
      response = get_response_from(uri)
      valid_status_groups = [Net::HTTPRedirection, Net::HTTPInformation, Net::HTTPSuccess ]
      valid_status_groups.should include(response.class.superclass)
      rescue RSpec::Expectations::ExpectationNotMetError
       message =  "Received a #{response.code} #{ response.msg } from #{href} on #{page_name}"
        fail message
      rescue
        message = "Invalid reference: #{href} found on #{page_name} page"
        fail message
    end
  end

  #this returns a hash with a response code and the url to help provide good fail detail
  def get_response_from(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = http.open_timeout = SimpliTest.config[:settings]["HTTP_TIMEOUT"] || 3
      request = Net::HTTP::Get.new(uri.request_uri)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
      http.request(request)
  end

  #FIXME: Code not used. Should be deleted
  def url_in_new_window
    if handles = page.driver.browser.window_handles rescue nil
      new_window = handles.last
      page.within_window(new_window) do
        return without_trailing_slash(current_url)
      end
    end
  end

  def without_trailing_slash(url)
    url.chomp('/')
  end

  def with_encoded_white_space(string)
    string.gsub(' ', '%20')
  end

  def with_unencoded_white_space(string)
    string.gsub('%20', ' ')
  end

  def normalize(url)
    normalized_uri = URI.parse(url).normalize
    url = normalized_uri.to_s
    encoded_url = URI::encode(url)
    without_trailing_slash(encoded_url)
  end

  def normalize_path(path)
    if path = is_url?(path)
      path = path.path
    end
    with_encoded_white_space(without_trailing_slash(path))
  end

  def wait_for(left_argument, right_argument)
    called_at = Time.now
    until left_argument > right_argument do
      past_wait_time = called_at < Time.now - SimpliTest.config['HTTP_TIMEOUT']
      return if past_wait_time
      sleep 1
    end
  end

  def comparable_urls_for(target_url, source_url)
    is_url?(target_url) ? [target_url, source_url].map{|u| normalize(u)} : [target_url, URI.parse(source_url).path]
  end

end

World(NavigationHelpers)
