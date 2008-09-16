require File.dirname(__FILE__) + '/spec_helper'

describe RemotePid do
  
  before(:each) do
    @uuid = "my-uuid"
    @local_pid = mock('pid', :uuid => "local-uuid", :_uid => "short")
    @connection = mock('Protocol', :send_raw_message => nil, 
                                   :address => ::URI.parse(em_addr),
                                   :local_pid => @local_pid)
                
    @options = {:uuid => @uuid}
    @cls = RemotePid
    @rpid = @cls.new(@connection, @options)
  end

  describe "inspectable", :shared => true do
    it "should be inspectable" do
      lambda{ @rpid.inspect }.should_not raise_error
    end
  end
  
  describe "#initialize" do
    it "should set connection" do
      @rpid._connection.should == @connection
    end

    it "should set uuid" do
      @rpid.uuid.should == @uuid
    end
        
    it "should not be killed" do
      @rpid.should_not be_killed
    end
    
    it_should_behave_like "inspectable"
    
    it "should have connection description in inspect" do
      @rpid.inspect.should =~ /on \S+ connected with local pid \S+/
    end
    
  end
    
  
  describe "#kill" do
    before(:each) do
      @connection.should_receive(:send_raw_message).once.with([:kill])
      @rpid.kill
    end
    
    it "should be killed" do
      @rpid.should be_killed
    end
    
    it "should ignore more kill calls" do
      @rpid.kill
      @rpid.kill
    end
    
    it_should_behave_like "inspectable"
    
    it "should have 'KILLED' in inspect" do
      @rpid.inspect.should =~ /KILLED/
    end
    
  end
  
  
  describe "method call proxying" do
    before(:each) do
      @connection.should_receive(:send_raw_message).once.with([:meth, :arg1, :arg2])
    end
    
    it "should allow direct call" do
      @rpid.meth(:arg1, :arg2)
    end
    
    it "should allow indirect call with send()" do
      @rpid.send(:meth, :arg1, :arg2)
    end
  end
    
end
