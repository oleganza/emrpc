$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')) )

require 'emrpc'
include EMRPC

require 'socket'

module AddressHelpers
  def em_host(host = ENV['EM_HOST'])
    host || '127.0.0.1'
  end

  def em_port(port = ENV['EM_PORT'])
    (port || 45_678).to_i
  end
  
  def em_random_port
    rand(10_000) + 40_000
  end

  def em_proto(proto = ENV['EM_PROTO'])
    proto || 'emrpc'
  end

  def em_addr(proto = em_proto, host = em_host, port = em_port)
    "#{proto}://#{host}:#{port}"
  end
end

class Object
  include AddressHelpers
end

module Fixtures
  class Person
    attr_accessor :name
    def initialize(options = {})
      @name = options[:name]
    end
  end

  class Paris
    attr_accessor :people, :options
  
    def initialize(ppl = 2, options = {})
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
    
    def run_slow(time = 2)
      sleep(time)
    end
    
    def run_exception
      raise SomeException, "paris message"
    end
    class SomeException < Exception; end
  end
end

module ThreadHelpers
  def create_threads(n, abort_on_exception = false, &blk)
    Array.new(n) do 
      t = Thread.new(&blk)
      t.abort_on_exception = abort_on_exception
      t
    end
  end
end

# Runs eventmachine reactor in a child thread,
# waits 0.5 sec. in a current thread.
# Returns child thread.
#
module EventMachine
  def self.run_in_thread(delay = 0.5, &blk)
    blk = proc{} unless blk
    t = Thread.new do
      EventMachine.run(&blk)
    end
    sleep delay
    t
  end
end

$em_thread ||= EventMachine.run_in_thread
