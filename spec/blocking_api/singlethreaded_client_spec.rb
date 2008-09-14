require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SinglethreadedClient do

  module ServerFixture
    class MyError < StandardError; end
    def send(from, meth, *args, &blk)
      if meth == :sum
        from.on_return(self, args.inject{|a,b|a+b})
      else
        from.on_raise(self, MyError.new("Raised!"))
      end
    end
    extend self # handy shortcuts
  end
  
  describe "blocking client", :shared => true do
    it "should return" do
      pending @client if String === @client
      @client.send(:sum, 1, 2, 42).should == 45
    end
    it "should raise" do
      pending @client if String === @client
      lambda { @client.send(:unknown) }.should raise_error(ServerFixture::MyError)
    end
  end
    
  describe "(simple mock)" do
    before(:each) do
      @client = Class.new do
        include ServerFixture
        include SinglethreadedClient
      end.new
    end
    it_should_behave_like "blocking client"
  end
    
  describe "(double-threaded)" do
    before(:each) do
      
      @channel = Queue.new
      @server = Thread.new do 
        while true
          data = @channel.shift
          ServerFixture.send(*data)
        end
      end
      @server.abort_on_exception = true
      @client = Class.new do
        attr_accessor :channel
        def send(from, *args, &blk)
          @channel.push([from, *args])
        end
      end.new
      @client.extend(SinglethreadedClient)
      @client.channel = @channel
    end
    
    it_should_behave_like "blocking client"
  end
end
