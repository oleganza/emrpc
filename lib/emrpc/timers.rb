module EMRPC
  # Default timers for :timer option in misc classes' configuration.
  module Timers
    EVENTED = Proc.new do |interval, proc| 
      EventMachine::PeriodicTimer.new(interval, &proc)
    end
  
    THREADED = Proc.new do |timeout, proc| 
      Thread.new do
        sleep(timeout)
        proc.call
      end
    end
    
    NOOP = Proc.new { }
  end
end
