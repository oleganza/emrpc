require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Blocking API" do
  class HelloWorld
    def action
      "Hello!"
    end
  end

  before(:all) do
    em_addr = "emrpc+unix:///tmp/emrpc-test.sock"
    
    @server = EMRPC::Server.new(:address => em_addr, 
                                :backend => HelloWorld.new)
    @server.start
    sleep 0.1
    
    @client = EMRPC::Client.new(em_addr)
    
    #@t = Thread.new do  
    #end
    sleep 0.1
  end
  
  after(:all) do
    @server.stop
    @client.kill_pid
    sleep 0.1
  end
  
  it "should access remote method" do
    #pending
    @client.action.should == "Hello!"
  end
end
