module EMRPC
  class Server
    attr_accessor :address, :wrapper
    def initialize(options)
      @address = options[:address] or raise ":address option is missing!"
      @wrapper = EventedWrapper.new(:backend => options[:backend])
    end
    
    def start
      @wrapper.bind(@address)
    end
    
    def stop
      @wrapper.kill
    end
  end 
end
