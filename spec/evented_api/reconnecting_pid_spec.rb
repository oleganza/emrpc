require File.dirname(__FILE__) + '/spec_helper'

describe ReconnectingPid do
  
  before(:each) do
    @options = {
      :max_backlog  => 666, 
      :max_attempts => 666, 
      :timeout      => 666, 
      :timer        => Timers::NOOP
    }
    @connection = mock('connection')
    @remote = mock('remote pid')
    @remote.should_receive(:is_a?).any_number_of_times.and_return{ |p|
      [RemotePid, Pid].include?(p) } 
    @pid = ReconnectingPid.allocate
    @pid.stub!(:connect).and_return(@connection)
  end

  def init_pid(pid, *args)
    pid.__send__(:initialize, *args)
  end
  
  describe "with normal connection" do
    before(:each) do
      
      # Expectations
      
      @remote.should_receive(:send).with(:quick, :brown).ordered
      @remote.should_receive(:send).with(:fox, :jumped).ordered
      @pid.should_receive(:connect).exactly(3).times.with(@remote).and_return{|p| @connection }
      
      # Scenario
      
      init_pid(@pid, @remote, @options)
      @pid.send(:quick, :brown)
      @pid.send(:fox, :jumped)
      @pid.connection_failed(@connection)
      @pid.connection_failed(@connection)
      @pid.connected(@remote)
    end
    
    it "should verify mocks expectations" do
    end
  end
  
  describe "with backlog error" do
    before(:each) do

    end
    
    it "should verify mocks expectations" do
      pending
    end
  end

  describe "with exceeding max. attempts" do
    before(:each) do
      
    end
    
    it "should verify mocks expectations" do
      pending
    end
  end

  describe "with exceeding timeout" do
    before(:each) do
      
    end
    
    it "should verify mocks expectations" do
      pending
    end
  end

  
end