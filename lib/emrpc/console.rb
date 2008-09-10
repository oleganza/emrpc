require 'irb'

# Runs eventmachine reactor in a child thread,
# waits 0.5 sec. in a current thread.
# Returns child thread.
#
module EventMachine
  def self.run_in_thread(delay = 0.25, &blk)
    blk = proc{} unless blk
    t = Thread.new do
      EventMachine.run(&blk)
    end
    sleep delay
    t
  end
end

module EMRPC
  module Console
    def self.included(klass)
      klass.module_eval do

        def setup
          $em_thread ||= EventMachine.run_in_thread
        end

        def help!
          puts ("
            n/a yet
            ".unindent!)
        end

      end
      klass.send(:include, EMRPC)
      klass.send(:setup)

      puts "EMRPC #{::EMRPC::VERSION} (help! for more info)"
    end # self.included
  end # Console
end # EMRPC
