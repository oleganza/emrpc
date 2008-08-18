require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "spec/rake/spectask"
require "fileutils"

def __DIR__
  File.dirname(__FILE__)
end

include FileUtils

NAME = "emrpc"

require "lib/emrpc/version"

def sudo
  ENV['EMRPC_SUDO'] ||= "sudo"
  sudo = windows? ? "" : ENV['EMRPC_SUDO']
end

def windows?
  (PLATFORM =~ /win32|cygwin/) rescue nil
end

def install_home
  ENV['GEM_HOME'] ? "-i #{ENV['GEM_HOME']}" : ""
end

##############################################################################
# Packaging & Installation
##############################################################################
CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache"]

desc "Run the specs."
task :default => :specs

task :emrpc => [:clean, :rdoc, :package]

spec = Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = EMRPC::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Oleg Andreev"
  s.email        = "oleganza@gmail.com"
  s.homepage     = "http://strokedb.com"
  s.summary      = "Efficient RPC library with evented and blocking APIs. In all ways better than DRb."
  s.bindir       = "bin"
  s.description  = s.summary
  s.executables  = %w( )
  s.require_path = "lib"
  s.files        = %w( README Rakefile TODO ) + Dir["{docs,bin,spec,lib,examples,script}/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README TODO )
  #s.rdoc_options     += RDOC_OPTS + ["--exclude", "^(app|uploads)"]

  # Dependencies
  s.add_dependency "eventmachine"
  s.add_dependency "rake"
  s.add_dependency "rspec"
  # Requirements
  s.requirements << "You need to install json (or json_pure), yaml, rack gems to use related features."
  s.required_ruby_version = ">= 1.8.4"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{#{sudo} gem install #{install_home} --local pkg/#{NAME}-#{EMRPC::VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{#{sudo} gem uninstall #{NAME}}
end
