module EMRPC
  module MarshalProtocol
    # Creates new protocol using specified dump/load interface.
    # Examples:
    #  1. include MarshalProtocol.new(Marshal)
    #  2. include MarshalProtocol.new(YAML)
    #  3. include MarshalProtocol.new(JSON)
    def self.new(marshal_const)
      mod = Module.new
      mod.module_eval <<-EOF, __FILE__, __LINE__
        def send_marshalled_message(msg)
          send_message(MarshalBackend.dump(msg))
        end
        def receive_message(msg)
          receive_marshalled_message(MarshalBackend.load(msg))
        rescue Exception => e
          rescue_marshal_error(e)
        end
      EOF
      mod.const_set(:MarshalBackend, marshal_const)
      mod
    end
    
    DEFAULT_CONST = Marshal
    
    # By default, include Marshal-based serialization module.
    def self.included(base)
      base.send(:include, new(DEFAULT_CONST))
      #STDERR.puts "# Info: #{self} included into #{base} directly: using #{self}.new(#{DEFAULT_CONST})."
    end
  end
end
