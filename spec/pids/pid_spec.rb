require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Pid do
  
  before(:all) do
    @pid_class = Class.new do 
      include Pid
    end
    @child_class = Class.new do
      include Pid
      attr_accessor :a, :b, :c
      def initialize(a, b)
        super
        @a = a
        @b = b
        @c = yield(@a, @b)
      end
    end
    @pid = @parent = @pid_class.new
  end
  
  describe "any local pid", :shared => true do
    
    it "should be kind of Pid module" do
      @pid.should be_kind_of(Pid)
    end
    
    it "should have uuid" do
      @pid.uuid.should_not be_nil
    end
    
    it "should have connected_pids uuid -> pid hash" do
      @pid.connected_pids.should be_kind_of(Hash)
    end
    
    it "should have options hash" do
      @pid.options.should be_kind_of(Hash)
    end
  end
  
  describe "new instance" do
    it_should_behave_like "any local pid"
    
    it "should have empty list of connected pids" do
      @pid.connected_pids.should be_empty
    end
  end

  describe "spawned from another pid" do
    before(:each) do
      @pid = @parent.spawn(@child_class, 1, 2){|a,b|  a + b + 30 }
    end
    
    it_should_behave_like "any local pid"
    
    it "should be initialized properly" do
      @pid.a.should == 1
      @pid.b.should == 2
      @pid.c.should == 33
    end
  end
  
  describe "tcp_spawned pid" do
    
    before(:all) do
      @parent = @pid
      @proto = em_proto
      @host = em_host
      EventMachine.reactor_running?.should == true
    end
    
    before(:each) do
      @port = em_port
      @addr = em_addr(@proto, @host, @port)
      @pid = @parent.tcp_spawn(@addr, @child_class, 1, 2){|a,b|  a + b + 30 }
    end
    
    after(:each) do
      @pid.kill
    end
    
    it_should_behave_like "any local pid"
    
    it "should be initialized properly" do
      @pid.a.should == 1
      @pid.b.should == 2
      @pid.c.should == 33
    end
    
    it "should start a TCP server" do
      lambda { TCPSocket.new(@host, @port)     }.should_not raise_error
      lambda { TCPSocket.new(@host, @port + 1) }.should raise_error(Errno::ECONNREFUSED)
    end
    
    describe "killed" do
      
      before(:each) do
        a = mock("pid1")
        b = mock("pid2")
        a.stub!(:disconnected).and_return(nil)
        b.stub!(:disconnected).and_return(nil)
        a.should_receive(:disconnected).once.with(@pid)
        b.should_receive(:disconnected).once.with(@pid)
        @pid.connected_pids = {"uuid1" => a, "uuid2" => b}
        @pid.kill
        sleep 1.3
      end
      
      it "should be killed" do
        @pid.should be_killed
      end
      
      it "should clear connections" do
        @pid.connected_pids.should be_empty
      end
      
      it "should take server down" do
        lambda { TCPSocket.new(@host, @port) }.should raise_error(Errno::ECONNREFUSED)
      end
      
    end # killed
    
  end # tcp_spawned

  describe "#connect" do
    
    before(:all) do
      @server_addr = em_addr
      @parent.tcp_spawn(em_addr)
    end
    
    after(:all) do
      
    end
    
  end
  
end
