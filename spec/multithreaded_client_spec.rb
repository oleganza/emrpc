require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MultithreadedClient, " with no timeouts" do
  include ThreadHelpers
  before(:each) do
    @mod = Module.new do
      def send_message(meth, args, blk)
        send(meth, *args, &blk)
      end
    end
    @backends = [ [ 1 ], [ 2 ], [ 3 ] ]
    @backends.each{|b| b.extend(@mod) }
    
    @client = MultithreadedClient.new(:backends => @backends, :timeout => 1)
  end
  it "should work with all backends" do
    ts = create_threads(10) do 
      loop { @client.send_message(:[], [ 0 ], nil) }
    end
    sleep 3
    ts.each {|t| t.kill}
  end
end

describe MultithreadedClient, " with PoolTimeout" do
  include ThreadHelpers
  before(:each) do
    @long_backend = Object.new
    class <<@long_backend
      def send_message(meth, args, blk)
        sleep 0.5
      end
    end
    @long_client = MultithreadedClient.new(:backends => [ @long_backend ], :timeout => 1)
  end
  
  it "should raise ThreadTimeout" do
    ts = create_threads(50) do # some of them will die
      @long_client.send_message(:some_meth, nil, nil)
    end
    create_threads(10, true) do 
      lambda {
        @long_client.send_message(:some_meth, nil, nil)
      }.should raise_error(PoolTimeout)
    end
    sleep 3
    ts.each {|t| t.kill}
  end
end
