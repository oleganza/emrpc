module EMRPC
  module Pids
    class Timer
      include Pid
      def initialize(pid, options)
        super
        @pid      = options[:pid] or raise "Option :pid is missing!"
        @interval = options[:interval]
        @delay    = options[:delay]
        @callback = options[:callback] || :on_timer
        if @interval
          EventMachine::PeriodicTimer.new(@interval) do
            @pid.send(@callback)
          end
        else
          @delay or raise "Options :delay or :interval are missing!"
          EventMachine::Timer.new(@delay) do
            @pid.send(@callback)
            kill
          end
        end
      end # initialize
    end # Timer < Pid
  end # Pids
end # EMRPC
