drivers = %w(selenium phantom chrome)
drivers_with_parallel = drivers + ["parallel"]

task :default => drivers_with_parallel.map { |d| "examples:#{d}" }.flatten

namespace :examples do
  drivers.each do |driver|
      Cucumber::Rake::Task.new(driver,"run features using #{driver}") do |t|
        t.profile=driver
    end
  end
  desc "run features using parallel_cucumber"
  task :parallel do
   puts "run features in parallel"
   `bundle exec parallel_cucumber features`
  end
end

