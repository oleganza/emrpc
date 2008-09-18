module EMRPC
  
    # TODO: allow passing undumped objects throughout the system.
    class ::Object
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
        raise "TODO: encode particular objects with recording references in the host_pid"
      end
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
        raise "TODO: decode particular objects with retrieving references from the host_pid"
      end
    end
    
    # Return the primitive value as is. 
    # It will be encoded/decoded using Marshal.dump/load methods.
    module PassThruCodec
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        self
      end
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        self
      end
    end
    
    [::Numeric, ::Symbol, ::NilClass, ::TrueClass, ::FalseClass, ::String].each do |c|
      c.send(:include, PassThruCodec)
    end
    
    # OPTIMIZE: make in-place encoding using Enumerable#each_with_index{|e,i| }
    class ::Array
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        inject([]) do |a, e|
          a.push(e.encode_b381b571_1ab2_5889_8221_855dbbc76242(ref))
        end
      end
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        inject([]) do |a, e|
          a.push(e.decode_b381b571_1ab2_5889_8221_855dbbc76242(ref))
        end
      end
    end
    
    # OPTIMIZE: make in-place encoding using Hash#each{|k,v| }
    class ::Hash
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        inject({}) do |h, (k,v)|
          h[k.encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)] = v.encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
          h
        end
      end
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        inject({}) do |h, (k,v)|
          h[k.decode_b381b571_1ab2_5889_8221_855dbbc76242(ref)] = v.decode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
          h
        end
      end
    end

    module Pid
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(ref)
        @marshallable_pid ||= Marshallable.new(@uuid)
      end
      
      # The purpose of that class is to discard all the class information about Pid before marshalling it.
      # The only thing we want to pass around is pid.uuid.
      #
      class Marshallable
        attr_accessor :uuid
        def initialize(uuid)
          @uuid = uuid
        end
        # TODO: support unknown pids (maybe instantiate RemotePid instance or ProxyPid or something)
        def decode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
          host_pid.find_pid(@uuid)
        end
        
        def inspect
          "#<Pid::Marshallable:#{_uid}>"
        end

        # shorter uuid for pretty output
        def _uid(uuid = @uuid)
          uuid && uuid[0,6]
        end
      end # Marshallable
    end # Pid
  
end # EMRPC
