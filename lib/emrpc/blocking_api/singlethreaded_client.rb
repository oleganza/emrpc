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
      mbox = @mbox
      super(self, *args)
      mbox.shift == :return ? (return mbox.shift) : (raise mbox.shift)
    end
    
    def on_return(pid, result)
      @mbox.push(:return)
      @mbox.push(result)
    end
    
    def on_raise(pid, exception)
      @mbox.push(:raise)
      @mbox.push(exception)
    end
        
  end
end
