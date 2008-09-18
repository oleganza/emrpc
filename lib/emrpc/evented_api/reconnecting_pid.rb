module EMRPC
  # ReconnectingPid collects all messages in the backlog buffer and tries to reconnect.
  # Calls self.on_raise() with the following exceptions:
  # * 
  #
  class ReconnectingPid
    include Pid
    
    DEFAULT_MAX_BACKLOG  = 256
    DEFAULT_MAX_ATTEMPTS = 5
    DEFAULT_TIMEOUT      = 5 # sec.
    DEFAULT_TIMER        = Timers::EVENTED
    
    # Arguments:
    #   address          Address if a pid or the pid itself to connect to.
    #
    # Options:
    #   :max_backlog     Maximum backlog size. BacklogError is raised when backlog becomes larger than 
    #                    the specified size. Default is 256 messages.
    #
    #   :max_attempts    Maximum number of connection attempts. AttemptsError is raised when this number is exceeded.
    #                    Counter is set to zero after each successful connection. Default is 5 attempts.
    #
    #   :timeout         Time interval in seconds. TimeoutError is raised when connection was not established
    #                    in the specified amount of time. Default is 5 seconds.
    #
    #   :timer           Proc which runs a periodic timer. Default is Timers::EVENTED. See EMRPC::Timers for more info.
    #   
    def initialize(address, options = {})
      super(address, options)
      
      @address = address

      # Options
      
      @max_backlog    = options[:max_backlog]  || DEFAULT_MAX_BACKLOG
      @max_attempts   = options[:max_attempts] || DEFAULT_MAX_ATTEMPTS
      @timeout        = options[:timeout]      || DEFAULT_TIMEOUT
      @timer          = options[:timer]        || DEFAULT_TIMER
      
      # Gentlemen, start your engines!
      
      @attempts = 1
      @backlog  = Array.new
      @timeout_thread = @timer.call([ @timeout, 1 ].max, method(:timer_action))
      connect(address)
    end
    
    def send(*args)
      if p = @rpid
        p.send(*args)
      else
        @backlog.push(args)
        if @backlog.size > @max_backlog
          on_raise(self, BacklogError.new("Backlog exceeded maximum size of #{@max_backlog} messages"))
        end
      end
    end
    
    def flush!
      while args = @backlog.shift
        send(*args)
      end
    end
    
    def connected(rpid)
      @rpid = rpid
      @attempts = 1
      flush!
    end
    
    def disconnected(rpid)
      @rpid = nil
      connect(@address) unless killed?
    end
    
    def connection_failed(conn)
      a = (@attempts += 1)
      if a > @max_attempts
        on_raise(self, AttemptsError.new("Maximum number of #{@max_attempts} connecting attempts exceeded"))
      end
      connect(@address)
    end
    
    def timer_action
      if @rpid 
        @state = nil
        return
      end
      
      if @state == :timeout
        @state = nil
        on_raise(self, TimeoutError.new("Failed to reconnect with #{@timeout} sec. timeout"))
      else
        @state = :timeout
      end
    end
          
    class ReconnectingError < StandardError; end
    class BacklogError      < ReconnectingError; end
    class AttemptsError     < ReconnectingError; end
    class TimeoutError      < ReconnectingError; end
    
  end # ReconnectingPid
end # EMRPC
