require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MethodProxy do
  before(:each) do
    @backend = [ 1, 2, 3 ]
    class <<@backend
      def send_message(meth, args, blk)
        send(meth, *args, &blk)
      end
      def id
        object_id
      end
    end
    @proxy = MethodProxy.new(@backend)
  end
  
  it "should proxy regular methods" do
    @proxy.size.should == @backend.size
    (@proxy*2).should == (@backend*2)
    @proxy.join(':').should == @backend.join(':')
  end 
  
  it "should proxy Object's methods" do
    @proxy.to_s.should   == @backend.to_s
    lambda { @proxy.to_str.should == @backend.to_str }.should raise_error(NoMethodError) # to_str is undefined
    @proxy.class.should  == @backend.class
    @proxy.id.should     == @backend.id
  end
  
  it "should inspect" do
    @proxy.inspect == %{#<MethodProxy:0x#{@proxy.__id__.to_s(16)} remote:#{@backend.inspect}>}
  end
end
