require 'thread'
module EMRPC
  class PoolTimeout < StandardError; end unless defined? PoolTimeout
  
  class AsyncPool
    attr_reader :pool, :backends, :queue, :backlog, :timeout, :timer
    # Options:
    #   :backends  - an array of backends implementing send(meth, *args) method.
    #   :backend   - specify a single backend instead of array of :backends (just a friendly shortcut)
    #   :pool      - an optional queue object of the available backends (default is Array.new)
    #   :backlog   - an optional queue object of the pending clients (default is Array.new)
    #   :worklog   - an optional queue of working callback-backend pairs.
    #   :timeout   - an optional timeout in seconds (default is 5 seconds)
    #   :timer     - optional proc, which accepts two arguments: +timeout+ and 
    #                another proc to be called every +timeout+ seconds.
    #                Default is Proc.new{|t,p| Thread.new{sleep(t); p.call}}.
    #   
    def initialize(options)
      @backends = options[:backend] && [options[:backend]] || options[:backends] or raise "No backends supplied!"
      @pool     = options[:pool] || ::Array.new
      @backlog  = options[:backlog] || ::Array.new
      @worklog  = options[:worklog] || ::Array.new
      @timeout  = options[:timeout] || 5
      @timer    = options[:timer] || Proc.new {|timeout, proc| Thread.new{sleep(timeout); proc.call} }
      @timer_thread = @timer.call(@timeout, method(:timer_action!))
      @backends_with_callbacks = @backends.map{|b| BackendWithCallback.new(self, b)}
      @backends_with_callbacks.each do |backend|
        @pool.push(backend)
      end
    end
    
    def send_from(callback, *send_args, &blk)
      if backend = @pool.shift
        backend.send_from(callback, *send_args, &blk)
      else
        @backlog.push([Time.now.to_i, callback, send_args, blk])
      end
    end
    
    # Delegates call to #send_from using default callback.
    def send(*send_args, &blk)
      send_from(@callback, *send_args, &blk)
    end
    
    def on_return(backend, callback, result)
      callback.on_return(result)
      return_backend(backend)
    end

    def on_raise(backend, callback, exception)
      callback.on_raise(exception)
      return_backend(backend)
    end
    
    def return_backend(backend)
      # If someone's waiting, yield, then reuse backend without putting it into the pool.
      if pair = @backlog.shift
        time, callback, send_args, blk = pair
        backend.send_from(callback, *send_args, &blk)
      # If no one is waiting, push into the pool.
      else
        @pool.push(backend)
      end
    end
    
    # Pushes :timeout message to a queue for all 
    # the threads in a backlog every @timeout seconds.
    def timer_action!
      return if @backlog.empty?
      now = Time.now
      timeout = @timeout
      size = @backlog.size
      while pair = @backlog.shift
        time, callback, send_args, blk = pair
        if now - time > timeout
          callback.on_raise(PoolTimeout.new("Thread #{Thread.current} waited #{seconds} seconds for the backend connection in a pool. Pool size is #{@backends.size}. Backlog size is #{size}: maybe too many threads are running concurrently. Increase the pool size or decrease the number of threads."))
        else
          # not timed out yet, put pair it back
          @backlog.push(pair)
        end
      end
    end
    
    # Holds a pair of callback and backend.
    class BackendWithCallback
      attr_accessor :owner, :callback, :backend
      def initialize(owner, backend)
        @owner   = owner
        @backend = backend
      end
      # send from the specified callback, but store the callback for
      # use in owner's callbacks
      def send_from(callback, *args, &blk)
        @callback = callback
        @backend.send_from(self, *args, &blk)
      end
      def on_return(result)
        @owner.on_return(@backend, @callback, result)
      end
      def on_raise(exception)
        @owner.on_raise(@backend, @callback, exception)
      end
    end

    
  end
end
