require 'thread'
module EMRPC
  class PoolTimeout < StandardError; end
  class MultithreadedClient
    attr_reader :pool, :backends, :timeout
    # Options:
    #   :backends  - an array of backends implementing send(meth, *args) method.
    #   :backend   - specify a single backend instead of array of :backends (just a friendly shortcut)
    #   :queue     - an optional queue object (default is Queue.new from the standard library)
    #   :timeout   - an optional timeout in seconds (default is 5 seconds)
    #   :timer     - optional proc, which accepts two arguments: +timeout+ and 
    #                another proc to be called every +timeout+ seconds.
    #                Default is Proc.new{|t,p| Thread.new{sleep(t); p.call}}.
    #   
    def initialize(options)
      @backends = options[:backend] && [options[:backend]] || options[:backends] or raise "No backends supplied!"
      @pool     = options[:queue] || ::Queue.new
      @timeout  = options[:timeout] || 5
      @timer    = options[:timer] || Proc.new {|timeout, proc| Thread.new{sleep(timeout); proc.call} }
      @timeout_thread = @timer.call(@timeout, method(:timer_action!))
      @backends.each do |backend|
        @pool.push(backend)
      end
    end
    
    def send(meth, *args, &blk)
      start = Time.now
      # wait for the available connections here
      # if @timeout_thread sent a :timeout message thru the queue, 
      # be ready to raise a PoolTimeout exception.
      while :timeout == (backend = @pool.shift)
        seconds = Time.now - start
        if seconds > @timeout
          raise PoolTimeout, "Thread #{Thread.current} waited #{seconds} seconds for backend connection in a pool. Pool size is #{@backends.size}. Maybe too many threads are running concurrently. Increase the pool size or decrease the number of threads."
        end
      end
      begin
        # Backend can throw its own exceptions which must be caught somewhere outside.
        backend.send(meth, *args, &blk)
      ensure # Always push backend to a pool after using it!
        @pool.push(backend)
      end
    end
    
    # Pushes :timeout message to a queue for all 
    # the threads in a backlog every @timeout seconds.
    def timer_action!
      @pool.num_waiting.times { @pool.push(:timeout) }
    end
    
  end
end
