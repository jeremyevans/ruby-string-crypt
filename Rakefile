require "rake"
require "rake/clean"

CLEAN.include %w'tmp string-crypt-*.gem lib'

desc "Build the gem"
task :package => :clean do
  sh %{gem build string-crypt.gemspec}
end

begin
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('string/crypt')

  desc "Run tests"
  task :test => :compile do
    sh "#{FileUtils::RUBY} -w test/test_string_crypt.rb"
  end
rescue LoadError
end
