require 'thread'
module EMRPC
  # Blocks the current thread around #send_from method and #on_return/#on_raise callbacks.
  class BlockingClient
    def initialize(options)
      @backend = options[:backend] or raise "Please specify :backend option!"
      @mbox = options[:mbox] || Queue.new
    end
    
    def send(*args)
      @backend.send_from(self, *args)
      @mbox.shift == :return ? (return @mbox.shift) : (raise @mbox.shift)
    end
        
    def on_return(result)
      @mbox.push(:return)
      @mbox.push(result)
    end
    
    def on_raise(exception)
      @mbox.push(:raise)
      @mbox.push(exception)
    end
    
  end
end
