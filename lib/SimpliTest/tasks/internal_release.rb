require 'bundler'
Bundler::GemHelper.class_eval do
  def release_gem_internally(built_gem_path=nil, force=false)
    guard_clean
    built_gem_path ||= build_gem
    tag_version { git_push } unless already_tagged?
    rubygem_push_internally(built_gem_path, force) if gem_push?
  end

  def rubygem_push_internally(path, force)
    require 'geminabox'
    if Pathname.new("~/.gem/geminabox").expand_path.exist?
      if on_cgi_network?
        command = force ? "gem inabox -o '#{path}'" : "gem inabox '#{path}'"
        sh('git push -u gitlab master --follow-tags')
        Bundler.ui.confirm "Pushed latest update and tags to gitlab"
        sh(command)
        Bundler.ui.confirm "Pushed #{name} #{version} to rubygems.cgifederal.com"
      else
        raise "You are not on the CGI VPN Network. Please connect to the VPN and try again"
      end
    else
      raise "Your geminabox credentials aren't set. Run `gem inabox` to set them."
    end
  end

  def on_cgi_network?
    Net::HTTP.get_response(URI.parse 'http://rubygems.cgifederal.com').code == '200' rescue false
  end
end



desc "Create tag v#{SimpliTest::VERSION} and build and push SimpliTest-#{SimpliTest::VERSION}.gem to rubygems.cgifederal.com"
task :internal_release, [:force] => :build do |t, args|
  force = args[:force] == 'force'
  Bundler::GemHelper.new.release_gem_internally(nil, force)
end

