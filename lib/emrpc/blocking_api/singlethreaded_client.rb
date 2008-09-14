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
    #attr_accessor :mbox
    
    def send(*args)
      unless mbox = @mbox
        mbox = @mbox = Queue.new
      end
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
