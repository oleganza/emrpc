module EMRPC
  class Client < BlankSlate
    attr_accessor :address
    # Single argument can be one of the following:
    # * Address of pid to connect to (e.g. "emrpc://localhost:4000/")
    # * Pid to connect to. Use this instead of address to pass some pid for in-process communication.
    # 
    # You can also pass optional params for EMRPC::ReconnectingPid.
    #
    def initialize(address, options = {})
      @address = address
      @pid = BlockingPid.new(@address, options)
    end
    
    def method_missing(meth, *args, &blk)
      @pid.blocking_send(meth, *args)
    end
    
    def kill_pid
      @pid.kill
    end
    
    class BlockingPid < ReconnectingPid
      include SinglethreadedClient
    end
    
  end # Client
end # EMRPC
