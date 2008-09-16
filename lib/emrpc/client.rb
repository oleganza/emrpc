module EMRPC
  class Client < BlankSlate
    attr_accessor :address
    # Single argument can be one of the following:
    # * Address of pid to connect to (e.g. "emrpc://localhost:4000/")
    # * Pid to connect to. Use this instead of address to pass some pid for in-process communication.
    # 
    # You can also pass optional params for EMRPC::EventedAPI::ReconnectingPid.
    #
    def initialize(address, options = {})
      @address = address
      @pid = BlockingPid.new(@address, options)
    end
    
    def method_missing(meth, *args, &blk)
      @pid.send(meth, *args)
    end
    
    class BlockingPid < EventedAPI::ReconnectingPid
      include SinglethreadedClient
    end
    
  end # Client
end # EMRPC
