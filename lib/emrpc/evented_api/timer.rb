module EMRPC
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
          @pid.__send__(@callback)
        end
      else
        @delay or raise "Options :delay or :interval are missing!"
        EventMachine::Timer.new(@delay) do
          @pid.__send__(@callback)
          kill
        end
      end
    end # initialize
  end # Timer
end # EMRPC
