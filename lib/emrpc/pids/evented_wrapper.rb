require 'uri'
module EMRPC
  module Pids
    class EventedWrapper
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
    
  end # Pids
end # EMRPC
