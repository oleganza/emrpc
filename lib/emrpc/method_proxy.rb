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
      @__emrpc_backend.send_message(meth, args, blk)
    end
    
    def id
      @__emrpc_backend.send_message(:id, EMPTY_ARGS, nil)
    end
    
    def to_s
      @__emrpc_backend.send_message(:to_s, EMPTY_ARGS, nil)
    end
    
    def to_str
      @__emrpc_backend.send_message(:to_str, EMPTY_ARGS, nil)
    end
    
    alias :__class__ :class
    def class
      @__emrpc_backend.send_message(:class, EMPTY_ARGS, nil)
    end
    
    def inspect
      "#<#{self.__class__.name}:0x#{__id__.to_s(16)} remote:#{@__emrpc_backend.send_message(:inspect, EMPTY_ARGS, nil)}>"
    end
    
  end
end
