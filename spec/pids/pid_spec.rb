require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
# Issues with evented networking testing:
# 1. TCP server is started and stopped asynchronously, so it requires to
#    wait 0.1 sec between start/stop actions to test normal operations order.
# 2. 
#
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
    
    # Assign names to the classes to make them dumpable.
    Object.send(:remove_const, :PidClass1) if defined?(::PidClass1)
    Object.send(:remove_const, :PidClass2) if defined?(::PidClass2)
    ::PidClass1 = @pid_class
    ::PidClass2 = @child_class
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


  describe "#connect" do
    
    before(:all) do
      #$DEBUG = true
      @server_addr = em_addr
      @server = @parent.tcp_spawn(@server_addr, @pid_class)
      @rpid_mock = an_instance_of(RemotePid)
      @parent.should_not_receive(:connecting_failed)
      @parent.should_receive(:_register_pid).once.with(@rpid_mock).and_return{|p| p}
      @parent.should_receive(:connected).once.with(@rpid_mock)
      @connection = @parent.connect(@server_addr)
    end
    
    after(:all) do
      @server.kill
      #$DEBUG = false
    end
    
    it "should wait until connection is established" do
      sleep 0.1
    end
    it "should verify mocks" do
      # this page is intentionally left blah-blah-blah
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
  
    
end
