require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Blocking API" do
  class HelloWorld
    def action
      "Hello!"
    end
  end

  before(:all) do
    @server = EMRPC::Server.new(:address => em_addr, 
                                :backend => HelloWorld.new)
    @server.start
    sleep 0.2
    
    @client = EMRPC::Client.new(em_addr)
  end
  
  it "should access remote method" do
    @client.action.should == "Hello!"
  end
end
