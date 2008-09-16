module EMRPC
  module EventedAPI    
    #
    # Initializes pids recursively upon any enumerable (responding to #each).
    #
    class ::Object
      # DEPRECATED
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        STDERR.puts "DEPRECATED"
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
        STDERR.puts "DEPRECATED"
      end
    end

    ###############################
    
    class ::Object
      def encode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
        raise "TODO: encode particular objects with recording references in the host_pid"
      end
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
        raise "TODO: decode particular objects with retrieving references from the host_pid"
      end
    end
    
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
    
    # FIXME: make in-place encoding using Enumerable#each_with_index{|e,i| }
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
        @marshallable_pid ||= MarshallablePid.new(@uuid)
      end
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        STDERR.puts "DEPRECATED"
        pid = host_pid.find_pid(@uuid)
        initialize_with_connection(pid._connection, pid.options)
      end
    end
    
    class MarshallablePid
      attr_accessor :uuid
      def initialize(uuid)
        @uuid = uuid
      end
      # TODO: support unknown pids (maybe instantiate RemotePid instance or ProxyPid or something)
      def decode_b381b571_1ab2_5889_8221_855dbbc76242(host_pid)
        host_pid.find_pid(@uuid)
      end
    end
  end # EventedAPI
end # EMRPC
