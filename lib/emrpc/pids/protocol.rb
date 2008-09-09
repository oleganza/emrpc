module EMRPC
  module Pids
    module Protocol
      attr_accessor :address
      attr_accessor :local_pid
      attr_accessor :remote_pid
      
      def post_init
      end
      
      def connection_completed
        # restore receive_marshalled_message
        class <<self
          alias receive_marshalled_message_normal receive_marshalled_message
          alias receive_marshalled_message        receive_marshalled_message_first
        end
        send_marshalled_message([:hello, @local_pid.options])
      end
      
      def receive_marshalled_message_first(msg)
        prefix, options = msg
        lpid = @local_pid
        prefix == :hello or return lpid.hello_failed(self, msg)
        @remote_pid = rpid = RemotePid.new(self, lpid, options)
        # we don't put +_register_pid+ into +connected+ callback to avoid unneccessary +super+ calls in callbacks.
        lpid._register_pid(rpid)
        lpid.connected(rpid)
        # restore receive_marshalled_message
        class <<self
          alias receive_marshalled_message receive_marshalled_message_normal
        end
      end
      
      def receive_marshalled_message(msg)
        @local_pid._send_dirty(*msg)
      end
                  
      def rescue_marshal_error(e)
        # FIXME: do something with this!
      end
      
      def unbind
        if @remote_pid
          # pid has been succesfully connected one day, but connection was lost.
          # we don't put +_unregister_pid+ into +connection_lost+ callback to avoid unneccessary +super+ calls in callbacks.
          @local_pid._unregister_pid(@remote_pid)
          @local_pid.disconnected(@remote_pid)
        else
          # there were no connection, connecting failed. 
          @local_pid.connecting_failed(self)
        end
      end
      
    end # Protocol
  end # Pids
end # EMRPC
