require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
Thread.abort_on_exception = true
describe BlockingClient do

  module ServerFixture
    class MyError < StandardError; end
    def received_message(callback, meth, *args, &blk)
      if meth == :sum
        callback.on_return(args.inject{|a,b|a+b})
      else
        callback.on_raise(MyError.new("Raised!"))
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
    
  describe "single-threaded example" do
    before(:each) do
      
      @backend_cls = Class.new do
        def send_from(callback, meth, *args, &blk)
          received_message(callback, meth, *args, &blk)
        end
      end
      @backend_cls.send(:include, ServerFixture)
      
      @client = BlockingClient.new(:backend => @backend_cls.new)
    end
    
    it_should_behave_like "blocking client"
  end
  
  describe "double-threaded example" do
    before(:each) do
      
      @channel = Queue.new
      @server = Thread.new do 
        while true
          data = @channel.shift
          ServerFixture.received_message(*data)
        end
      end
      @client_protocol_cls = Class.new do
        attr_accessor :channel
        def send_from(callback, meth, *args, &blk)
          @channel.push([callback, meth, *args])
        end
      end
      @client_protocol = @client_protocol_cls.new
      @client_protocol.channel = @channel
      @client = BlockingClient.new(:backend => @client_protocol)
    end
    
    it_should_behave_like "blocking client"
  end
  
  describe "example with EventMachine" do
    before(:each) do
      @client = "not yet implemented"
    end
    it_should_behave_like "blocking client"
  end
  
  
end
