require 'thread'
module EMRPC
  # Sends all the messages to a specified backend
  # FIXME: deal with Object's methods gracefully.
  class MethodProxy
    EMPTY_ARGS = [ ].freeze
    attr_reader :__emrpc_backend
    def initialize(backend)
      @__emrpc_backend = backend
    end
    
    def method_missing(meth, *args, &blk)
      @__emrpc_backend.send(meth, *args, &blk)
    end
    
    def id
      @__emrpc_backend.send(:id)
    end

    def to_i
      @__emrpc_backend.send(:to_i)
    end
        
    def to_s
      @__emrpc_backend.send(:to_s)
    end
    
    def to_str
      @__emrpc_backend.send(:to_str)
    end
    
    def is_a?(type)
      @__emrpc_backend.send(:is_a?, type)
    end
    
    alias :__class__ :class
    def class
      @__emrpc_backend.send(:class)
    end
    
    # Marshalling - just return a backend
    
    def marshal_dump
      @__emrpc_backend
    end
    
    def marshal_load(data)
      initialize(data)
    end
    
    
    def inspect
      "#<#{self.__class__.name}:0x#{__id__.to_s(16)} remote:#{@__emrpc_backend.send(:inspect)}>"
    end
    
  end
end
