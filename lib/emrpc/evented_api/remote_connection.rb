module EMRPC
  
    module RemoteConnection
      attr_accessor :address
      attr_accessor :local_pid
      attr_accessor :remote_pid
      
      #
      # IMPORTANT: server doesn't trigger #connection_completed callback.
      #     
      def post_init
        # setup single-shot version of receive_marshalled_message
        class <<self
          alias_method :receive_marshalled_message, :receive_handshake_message
        end
      end
      
      #
      # Handshake protocol
      #
      def connection_completed
        send_handshake_message(@local_pid.options)
      end
      
      def send_handshake_message(arg)
        @__sent_handshake = true
        send_marshalled_message([:handshake, arg])
      end
      
      def receive_handshake_message(msg)
        prefix, options = msg
        lpid = @local_pid
        prefix == :handshake or return lpid.handshake_failed(self, msg)
        rpid = RemotePid.new(self, options)
        # restore receive_marshalled_message
        class <<self
          alias_method :receive_marshalled_message, :receive_regular_message
        end
        unless @__sent_handshake # server-side
          send_handshake_message(@local_pid.options)
        end
        @remote_pid = lpid.connection_established(rpid, self)
      end
      
      #
      # Regular protocol
      #
      def send_raw_message(args)
        send_marshalled_message(args.encode_b381b571_1ab2_5889_8221_855dbbc76242(@local_pid))
      end
      
      def receive_regular_message(msg)
        lpid = @local_pid
        lpid.send(*(msg.decode_b381b571_1ab2_5889_8221_855dbbc76242(lpid)))
      end
      
      def rescue_marshal_error(e)
        raise e
      end
      
      def unbind
        if @remote_pid
          # pid has been succesfully connected one day, but connection was lost.
          # we don't put +_unregister_pid+ into +connection_lost+ callback to avoid unneccessary +super+ calls in callbacks.
          rpid = @remote_pid
          @remote_pid = nil
          @local_pid.connection_unbind(rpid, self)
        else
          # there were no connection, connecting failed. 
          @local_pid.connection_failed(self)
        end
      end
      
    end # RemoteConnection
  
end # EMRPC
