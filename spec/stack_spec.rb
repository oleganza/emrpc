require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
  
describe Stack do
  
  before(:each) do
  
    module A
      def post_init
        
      end
      def in(data)
        down([:in_A, data])
      end
      def out(data)
        up([:out_A, data])
      end
    end
  
    module B
      def in(data)
        down([:in_B, data])
      end
      def out(data)
        up([:out_B, data])
      end
    end
  
    module C
      def in(data)
        down([:in_C, data])
      end
      def out(data)
        up([:out_C, data])
      end
    end
    
    @connection_mod = Stack.new(A, B, C)
    @connection_mod.should be_kind_of(Module)
    
    @connection = Object.new
    @connection.extend(@connection_mod)
    
  end
  
  it "should work" do
    
    @connection.config = 1
    
    @connection.receive_data("raw data")
    
    
  end
  
end
