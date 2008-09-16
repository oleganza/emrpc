require 'thread'
module EMRPC
  # Blocks the current thread around #send_from method and #on_return/#on_raise callbacks.
  #
  # Example:
  #   class BlockingPid
  #     include Pid
  #     include BlockingClient
  #   end
  #
  #
  module SinglethreadedClient
    MBOX = 'SinglethreadedClient::MBOX'
    
    # Initialization method-1
    def initialize(*args, &blk)
      super(*args, &blk)
      @mbox = Queue.new
    end
    
    # Initialization method-2
    def self.extended(obj)
      obj.instance_variable_set(:@mbox, Queue.new)
    end
    
    def send(*args)
      #p [self, :send, :thread, Thread.current.object_id]
      #@mbox = mbox = (Thread.current[MBOX] ||= Queue.new)
      mbox = @mbox
      super(self, *args)
      if mbox.shift == :return
        return mbox.shift
      else
        raise mbox.shift
      end
    end
    
    def on_return(pid, result)
      #p [self, :on_return, :thread, Thread.current.object_id]
      @mbox.push(:return)
      @mbox.push(result)
    end
    
    def on_raise(pid, exception)
      #p [self, :on_raise, :thread, Thread.current.object_id]
      @mbox.push(:raise)
      @mbox.push(exception)
    end
        
  end
end
