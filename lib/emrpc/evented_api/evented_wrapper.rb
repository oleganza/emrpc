require 'uri'
module EMRPC  
  class EventedWrapper
    include Pid
    attr_accessor :backend
    
    def initialize(options = {})
      super
      @backend = options[:backend] or raise ":backend option is missing!"
    end
    
    def send(from, msg, *args)
      #p [self, :send, {:from => from, :msg => msg, :args => args}]
      begin
        r = @backend.send(msg, *args)
        #p ["EventedWrapper returns", {:from => from, :send => [:on_return, self, r]}]
        from.send(:on_return, self, r)
      rescue => e
        from.send(:on_raise, self, e)
      end
    end
    
    def pid_class_name
      "EventedWrapper"
    end
    
  end # EventedWrapper
end # EMRPC
