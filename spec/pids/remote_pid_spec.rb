require File.dirname(__FILE__) + '/spec_helper'

describe RemotePid do
  
  before(:each) do
    @uuid = "my-uuid"
    @connection = mock('Protocol', :send_marshalled_message => nil, 
                                   :address => ::URI.parse(em_addr),
                                   :local_pid => mock('pid', :uuid => "local-uuid"))
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
    
    it "should set options" do
      @rpid.options.should == @options
    end
    
    it "should not be killed" do
      @rpid.should_not be_killed
    end
    
    it_should_behave_like "inspectable"
    
    it "should have connection description in inspect" do
      @rpid.inspect.should =~ /on \S+ connected with local pid \S+/
    end
    
  end
  
  
  describe "marshal_dump/marshal_load" do
    it "should not raise errors" do
      lambda { Marshal.dump(@rpid) }.should_not raise_error
      lambda { Marshal.load(Marshal.dump(@rpid)) }.should_not raise_error
    end
    it "should dump uuid" do
      @rpid.marshal_dump.should == @uuid
    end
    
    describe "loaded" do
      before(:each) do
        rpid = @cls.allocate
        rpid.marshal_load(@rpid.marshal_dump)
        @rpid = rpid
      end
      
      it "should have uuid" do
        @rpid.uuid.should == @uuid
      end
      
      it "should not have options" do
        @rpid.options.should be_nil
      end
      
      it "should not have _connection" do
        @rpid._connection.should be_nil
      end
      
      it_should_behave_like "inspectable"
      
      it "should have 'NO CONNECTION' text in inspect" do
        @rpid.inspect.should =~ /NO CONNECTION/
      end
      
      describe "#_initialize_pids_recursively_d4d309bd" do
        before(:each) do
          @options = {:uuid => @uuid}
          @hosted_rpid = mock('Hosted remote pid', 
                              :options => @options, 
                              :_connection => @connection)
          @host_pid = mock('Host pid')
          @host_pid.stub!(:find_pid)
          @host_pid.should_receive(:find_pid).once.with(@uuid).and_return(@hosted_rpid)
          @rpid._initialize_pids_recursively_d4d309bd!(@host_pid)
        end
        
        it "should set options" do
          @rpid.options.should == @options
        end
        
        it "should set _connection" do
          @rpid._connection.should == @connection
        end
        
        it "should keep uuid" do
          @rpid.uuid.should == @uuid
        end
      end # _initialize_pids_recursively_d4d309bd!
    end # loaded
  end # marshal
  
  
  describe "#kill" do
    before(:each) do
      @connection.should_receive(:send_marshalled_message).once.with([:kill])
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
      @connection.should_receive(:send_marshalled_message).once.with([:meth, :arg1, :arg2])
    end
    
    it "should allow direct call" do
      @rpid.meth(:arg1, :arg2)
    end
    
    it "should allow indirect call with send()" do
      @rpid.send(:meth, :arg1, :arg2)
    end
  end
    
end
