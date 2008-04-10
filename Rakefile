require 'rubygems'
require 'spec'
require 'lib/pottery'

begin
  require 'echoe'

  Echoe.new("pottery", Pottery::VERSION) do |m|
    m.author = ["Rob McKinnon"]
    m.email = ["rob ~@nospam@~ rubyforge.org"]
    m.description = File.readlines("README").first
    m.rubyforge_name = "pottery"
    m.rdoc_options << '--inline-source'
    m.rdoc_pattern = ["README", "CHANGELOG", "LICENSE"]
    m.dependencies = ["soup =0.1.5", "morph =0.1.4"]
  end

rescue LoadError
  puts "You need to install the echoe gem to perform meta operations on this gem"
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/pottery.rb"
end
