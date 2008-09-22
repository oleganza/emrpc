module EMRPC
  module ProtocolMapper
    #
    # Configuration
    #
    MAP = Hash.new
    
    def self.register_protocol(scheme, suffix)
      MAP[scheme] = suffix
      self
    end
    
    # Default mapping
    register_protocol "emrpc",      :emrpc_tcp
    register_protocol "unix",       :emrpc_unix
    register_protocol "emrpc+unix", :emrpc_unix
    register_protocol "http",       :http_json
    
    #
    # Abstract API
    # 
    def make_client_connection(*args, &blk)
      make_some_connection(:client, *args, &blk)
    end
    
    def make_server_connection(*args, &blk)
      make_some_connection(:server, *args, &blk)
    end
    
  private
    def make_some_connection(sfx, addr, handler, &blk)
      addr = addr.parsed_uri
      pfx = MAP[addr.scheme]
      __send__("#{pfx}_#{sfx}_connection", addr, handler, &blk)
    end
    
    #
    # Particular protocols
    #
    def emrpc_tcp_client_connection(addr, handler, &blk)
      EventMachine.connect(addr.host, addr.port, handler, &blk)
    end

    def emrpc_tcp_server_connection(addr, handler, &blk)
      EventMachine.start_server(addr.host, addr.port, handler, &blk)
    end
    
    def emrpc_unix_client_connection(addr, handler, &blk)
      EventMachine.connect_unix_domain(addr.path, handler, &blk)
    end

    def emrpc_unix_server_connection(addr, handler, &blk)
      EventMachine.start_unix_domain_server(addr.path, handler, &blk)
    end
    
  end # ProtocolMapper
end # EMRPC
