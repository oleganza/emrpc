require 'uri'
module EMRPC
  module EventedAPI
    class EventedWrapper
      include Pid
      attr_accessor :backend
      
      def initialize(options = {})
        super
        @backend = options[:backend] or raise ":backend option is missing!"
      end
      
      def send(from, msg, *args)
        begin
          r = @backend.send(msg, *args)
          from.send(:on_return, self, r)
        rescue => e
          from.send(:on_raise, self, e)
        end
      end
    end
    
  end # EventedAPI
end # EMRPC
