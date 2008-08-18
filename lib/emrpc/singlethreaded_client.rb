require 'thread'
module EMRPC
  class ConnectionTimeout < StandardError; end
  class SinglethreadedClient
    def initialize(options)
      
    end
    
    def send_message(meth, args, blk)
      start = Time.now
      # TODO...
    end
    
  end
end
