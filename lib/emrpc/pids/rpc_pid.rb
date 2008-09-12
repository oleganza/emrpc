require 'uri'
module EMRPC
  module Pids
    class RPCServer
      include Pid
      attr_accessor :backend
      
      def initialize(options = {})
        @backend = options[:backend]
      end
      
      def send(from, msg, *args)
        begin
          r = @backend.send(msg, *args)
          from.on_return(self, r)
        rescue => e
          from.on_raise(self, e)
        end
      end
    end
    
    class RPCClient
      include Pid
      attr_accessor :remote
      
      def send(msg, *args)
        @remote.send(self, msg, *args)
      end
      
      def on_return(from, r)
      end
      
      def on_raise(from, e)
      end
    end
  end
end
