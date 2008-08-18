require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SinglethreadedClient do
  include ThreadHelpers
  before(:each) do
    @backend= [1, 2, 3]
    class <<@backend
      def send_message(meth, args, blk)
        send(meth, *args, &blk)
      end
    end
    @client = SinglethreadedClient.new(:backend => @backend, :timeout => 1)
  end
  
  it "should work without errors with regular methods" do
    @client.send_message(:size, nil, nil).should == 3
    @client.send_message(:join, [":"], nil).should == "1:2:3"
    @client.send_message(:map, nil, proc{|e| e.to_s}).should == %w[1 2 3]
  end

  
  
end