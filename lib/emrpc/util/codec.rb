module EMRPC
  module EventedAPI
    #
    # Initializes pids recursively upon any enumerable (responding to #each).
    #
    class ::Object
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        return unless respond_to?(:each)
        each do |*args|
          args.each do |a|
            a._initialize_pids_recursively_d4d309bd!(host_pid)
          end
        end
      end # _initialize_pids_recursively_d4d309bd!
    end # ::Object
    
    class ::String
      def _initialize_pids_recursively_d4d309bd!(host_pid)
      end
      
      def parsed_uri
        URI.parse(self)
      end
    end
    
    class ::URI::Generic
      def parsed_uri
        self
      end
    end

    ###############################
    
    class ::Object
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        raise "TODO: encode particular objects"
      end
    end
        
    class ::String
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        Marshal.dump(self)
      end
    end

    module EventedAPI::Pid
      def marshallable_container
        @marshallable_container ||= MarshallableContainer.new(@uuid)
      end
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        Marshal.dump(self.marshallable_container)
      end
    end
    
    class MarshallableContainer
      attr_accessor :uuid
      def initialize(uuid)
        @uuid = uuid
      end
    end    
  end # EventedAPI
end # EMRPC
