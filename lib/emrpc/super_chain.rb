module EMRPC
  # def receive_data(data, *args)
  #   return super(*args) if data == PASS_TO_SUPER
  # end
  #
  # def send_data(data, *args)
  #   return super(*args) if data == PASS_TO_SUPER
  # end

  module SuperChain
    def self.combine_modules(*modules)
      Module.new do
        modules.each {|m| include m }
      end
    end
    
    
    
    PASS_TO_SUPER = Object.new.freeze
  end
end
