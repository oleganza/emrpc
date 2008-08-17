$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')) )

require 'emrpc'
include EMRPC

EM_HOST =  ENV['EM_HOST'] || "127.0.0.1"
EM_PORT = (ENV['EM_PORT'] || 4567).to_i

module Fixtures
  class Person
    attr_accessor :name
    def initialize(options = {})
      @name = options[:name]
    end
  end

  class Paris
    attr_accessor :people, :options
  
    def initialize(ppl, options = {})
      @options = options
      @people = Array.new(ppl){ Person.new }
      @name = "Paris"
    end
  
    def translate(english_word)
      "le #{english_word}" # :-)
    end
  
    def visit(person)
      people << person
      people.size
    end
    
    def run_exception
      raise SomeException, "paris message"
    end
    class SomeException < Exception; end
  end
end

# Runs eventmachine reactor in a child thread,
# waits 0.5 sec. in a current thread.
# Returns child thread.
#
module EventMachine
  def self.run_in_thread(delay = 0.5, &blk)
    t = Thread.new do
      EventMachine.run(&blk) 
    end
    sleep delay
    t
  end
end
