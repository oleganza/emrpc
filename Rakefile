require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "spec/rake/spectask"
require "fileutils"


##############################################################################
# Automated tests
##############################################################################

desc "Run specs"
task :spec  => :'specs:spec'
task :specs => :'specs:spec'

namespace :specs do  
  desc "Run specs"
  task :spec do
    system("spec spec -c")
  end
  
  desc "Runs specs set by SPECS_PATH (default is 'spec') in a loop detecting random errors"
  task :loop do
    def run_spec_iteration(path = "spec", counter = 0)
      r = `spec #{path}`
      if r =~ /[\A\.PFE][FE][\.PFE\z]/
        puts r
        counter + 1
      else 
        counter
      end
    end
    path = ENV['SPECS_PATH'] || "spec"
    puts "Using #{path.inspect} path. (See SPECS_PATH environment variable.)"
    iters = (ENV['SPECS_ITERS'] || 10_000).to_i
    puts "#{iters} iterations. (See SPECS_ITERS environment variable.)"
    fs = 0
    iters.times do |i| 
      puts "Iterations: #{i}   Failures: #{fs}"
      fs = run_spec_iteration(path, fs)
    end
  end
end


##############################################################################
# Packaging & Installation
##############################################################################

def __DIR__
  File.dirname(__FILE__)
end

include FileUtils

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

CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache"]

desc "Run the specs."
task :default => :specs

task :emrpc => [:clean, :rdoc, :package]

RUBY_FORGE_PROJECT  = "emrpc"
PROJECT_URL         = "http://oleganza.com/"
PROJECT_SUMMARY     = "Efficient RPC library with evented and blocking APIs. In all ways better than DRb."
PROJECT_DESCRIPTION = PROJECT_SUMMARY

AUTHOR = "Oleg Andreev"
EMAIL  = "oleganza@gmail.com"

GEM_NAME    = "emrpc"
PKG_BUILD   = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
GEM_VERSION = EMRPC::VERSION + PKG_BUILD

RELEASE_NAME    = "REL #{GEM_VERSION}"

require "extlib/tasks/release"

spec = Gem::Specification.new do |s|
  s.name         = GEM_NAME
  s.version      = GEM_VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = AUTHOR
  s.email        = EMAIL
  s.homepage     = PROJECT_URL
  s.summary      = PROJECT_SUMMARY
  s.bindir       = "bin"
  s.description  = s.summary
  s.executables  = %w( em_console )
  s.require_path = "lib"
  s.files        = %w( README Rakefile TODO MIT-LICENSE ) + Dir["{docs,bin,spec,lib,examples,script}/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README TODO MIT-LICENSE )
  #s.rdoc_options     += RDOC_OPTS + ["--exclude", "^(app|uploads)"]

  # Dependencies
  s.add_dependency "eventmachine"
  s.add_dependency "rake"
  s.add_dependency "rspec"
  
  # See sources on github.com/oleganza
  s.add_dependency "gem_console"
  
  # Requirements
  s.requirements << "You need to install the json (or json_pure), yaml, rack gems to use related features."
  s.required_ruby_version = ">= 1.8.4"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{#{sudo} gem install #{install_home} --local pkg/#{GEM_NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{#{sudo} gem uninstall #{GEM_NAME}}
end
