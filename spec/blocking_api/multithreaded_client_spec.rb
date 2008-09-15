require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MultithreadedClient, " with no timeouts" do
  include ThreadHelpers
  before(:each) do
    @backends = [ [ 1 ], [ 2 ], [ 3 ] ]
    
    @client = MultithreadedClient.new(:backends => @backends, :timeout => 1)
  end
  it "should work with all backends" do
    @results = []
    ts = create_threads(200) do 
      while true
        @results << @client.send(:[], 0)
      end
    end
    sleep 3
    ts.each {|t| t.kill}
    
    # Average respond should be 2.0 (all backends are equally loaded)
    avg = @results.inject{|a,b| a + b } / @results.size.to_f
    avg.should be_close(2, 0.4)
  end
end

describe MultithreadedClient, " with PoolTimeout" do
  include ThreadHelpers
  before(:each) do
    @long_backend = Object.new
    class <<@long_backend
      def send(meth, *args, &blk)
        sleep 0.4
      end
    end
    @long_client = MultithreadedClient.new(:backend => @long_backend, :timeout => 1)
  end
  
  it "should raise ThreadTimeout" do
    @timeouts = Array.new
    ts = create_threads(50) do # some of them will die, but at least 10 - will not.
      begin
        @long_client.send(:some_meth)
      rescue PoolTimeout
        @timeouts.push(1)
      end
    end
    ts.map{|t| t.join}
    total = @timeouts.inject(0){|a,b| a + b}
    total.should > 10
    total.should < 50
  end
end
