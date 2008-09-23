require 'thread'
module EMRPC
  # Blocks the current thread around #send_from method and #on_return/#on_raise callbacks.
  #
  # Example:
  #   class BlockingPid
  #     include Pid
  #     include SinglethreadedClient
  #   end
  #
  #
  module SinglethreadedClient
    MBOX = 'SinglethreadedClient::MBOX'
    
    # Initialization method-1
    def initialize(*args, &blk)
      super(*args, &blk)
      initialize_singlethreaded_client
    end
    
    # Initialization method-2
    def self.extended(obj)
      obj.initialize_singlethreaded_client
    end
    
    def initialize_singlethreaded_client
      @outbox = Queue.new
      @inbox = Queue.new
      @acceptor = Thread.new(self, @outbox, @inbox) do |rcvr, obox, ibox|
        while 1
          args = obox.pop
          break if args == FINISH_ACCEPTOR
          rcvr.send(*args)
        end
      end
    end
    
    FINISH_ACCEPTOR = Object.new.freeze
    def stop
      @outbox.push(FINISH_ACCEPTOR)
    end
    
    def blocking_send(*args)
      @outbox.push([:send, self, *args])
      mbox = @inbox
      if mbox.shift == :return
        return mbox.shift
      else
        raise mbox.shift
      end
    end
    
    def on_return(pid, result)
      @inbox.push(:return)
      @inbox.push(result)
    end
    
    def on_raise(pid, exception)
      @inbox.push(:raise)
      @inbox.push(exception)
    end
    
    def pid_class_name
      "SinglethreadedClient"
    end
    
  end # SinglethreadedClient
end # EMRPC
