# This puts start_server, stop_server calls into the queue to ensure proper delays between them.

module ::EventMachine
  module EmStartStopTimeouts
    # Use case: 
    #   started localhost:4005 (signature4005)
    #   stopped signature4005
    #   started localhost:4005 (signature4005)
    #
    def queued_start_server(host, port, *args, &blk)
      @servers_m_queue ||= ServersManipulationQueue.new
      @servers_m_queue.start_server(host, port, *args, &blk)
    end
    
    def queued_stop_server(signature, *args, &blk)
      @servers_m_queue ||= ServersManipulationQueue.new
      @servers_m_queue.stop_server(signature, *args, &blk)
    end
    
    class ServersManipulationQueue
      def initialize
        @ports = {}
        @signs = {}
        @em = EventMachine
      end
      
      def start_server(host, port, *args, &blk)
        if @ports[port]
          sleep 0.1 if Time.now - @ports[port][1] < 1
          s = @ports[port].first
          @ports[port] = nil
          @signs[s] = nil
        end
        s = @em.non_queued_start_server(host, port, *args, &blk)
        @ports[port] = [s, Time.now]
        @signs[s] = port
        s
      end
      
      def stop_server(s, *args, &blk)
        port = @signs[s]
        sleep 0.1 if Time.now - @ports[port][1] < 1
        r = @em.non_queued_stop_server(s, *args, &blk)
        @ports[port] = [s, Time.now]
        r
      end
    end
  end # EmStartStopTimeouts
  
  extend EmStartStopTimeouts
  
  class <<self
    alias non_queued_start_server start_server
    alias non_queued_stop_server  stop_server
    unless $EM_DISABLE_QUEUED_OVERRIDES
      alias start_server queued_start_server
      alias stop_server  queued_stop_server
    end
  end
  
end # EM
