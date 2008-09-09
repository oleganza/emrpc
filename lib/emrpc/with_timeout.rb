module EMPRC
  
  class RequestTimeout < StandardError; end unless defined? RequestTimeout
  class BackendBusy < StandardError; end unless defined? BackendBusy
  
  # This module must be mixed into backend class.
  module WithTimeout
    def initialize(options)
      @timeout        = options[:timeout] || 5
      @timer          = options[:timer] || Timers::EVENTED
      @timeout_thread = @timer.call([ @timeout/2, 1 ].max, method(:timer_action))
      @callback_proxy = CallbackProxy.new
      super
    end
    
    def send_from(callback, *args, &blk)
      proxy = @callback_proxy
      if proxy.busy?
        raise BackendBusy, "RequestTimeout exception was raised recently, but backend hasn't responded yet."
      end
      @start_send = Time.now.to_i
      proxy.callback = callback
      super(proxy, *args, &blk)
    end

    def timer_action
      if @start_send && ((delta = Time.now.to_i - @start_send) > @timeout)
        @callback_proxy.on_timeout(RequestTimeout.new("Request timeout! (waited #{delta} seconds)"))
      end
    end  
    
    class CallbackProxy
      attr_accessor :callback, :busy
      def on_return(result)
        return @busy = false if @busy
        @callback.on_return(result)
      end
    
      def on_raise(exception)
        return @busy = false if @busy
        @callback.on_raise(exception)
      end
      
      def on_timeout(exception)
        @busy = true
        @callback.on_raise(exception)
      end
      
      def busy?
        @busy
      end
    end # CallbackProxy
    
  end # WithTimeout
end # EMRPC
