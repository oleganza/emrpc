require File.dirname(__FILE__) + '/spec_helper'

describe ReconnectingPid do
  extend MockDescribe
  
  before(:each) do
    @options = {
      :max_backlog  => 666, 
      :max_attempts => 666, 
      :timeout      => 666, 
      :timer        => Timers::NOOP
    }
    @connection = mock('connection')
    @remote = mock('remote pid')
          
    # We use allocate because initialize fires #connect before it is stubbed. 
    # See init_pid helper.
    @pid = ReconnectingPid.allocate 
    @pid.stub!(:connect).and_return(@connection)
  end

  def init_pid(overrides = {})
    params = {:local_pid => @pid, :remote_pid => @remote }.merge(@options).merge(overrides)
    local  = params.delete(:local_pid)
    remote = params.delete(:remote_pid)
    local.__send__(:initialize, remote, params)
  end
  
  mock_describe "with normal connection" do
    @remote.should_receive(:send).with(:quick, :brown).ordered
    @remote.should_receive(:send).with(:fox, :jumped).ordered
    @pid.should_receive(:connect).exactly(3).times.with(@remote).and_return{|p| @connection }
    
    init_pid(:max_backlog => 2, :max_attempts => 3)
    @pid.send(:quick, :brown)
    @pid.send(:fox, :jumped)
    @pid.connection_failed(@connection)
    @pid.connection_failed(@connection)
    @pid.connected(@remote)
  end
  
  mock_describe "with backlog error" do
    @remote.should_not_receive(:send)
    @pid.should_receive(:connect).once.with(@remote).and_return{|p| @connection }
    @pid.should_receive(:on_raise).once.with(@pid, an_instance_of(ReconnectingPid::BacklogError))
    
    init_pid(:max_backlog => 2)
    @pid.send(:quick, :brown)
    @pid.send(:fox, :jumped)
    @pid.send(:this_should_overflow_the_backlog)
  end

  mock_describe "with exceeding max. attempts" do
    @remote.should_not_receive(:send)
    @pid.should_receive(:connect).exactly(3).times.with(@remote).and_return{|p| @connection }
    @pid.should_receive(:on_raise).once.with(@pid, an_instance_of(ReconnectingPid::AttemptsError))
    
    init_pid(:max_attempts => 2)
    @pid.send(:quick, :brown)
    @pid.connection_failed(@connection)
    @pid.connection_failed(@connection)
  end

  mock_describe "with exceeding timeout" do
    @remote.should_not_receive(:send)
    @pid.should_receive(:connect).exactly(3).times.with(@remote).and_return{|p| @connection }
    @pid.should_receive(:on_raise).once.with(@pid, an_instance_of(ReconnectingPid::TimeoutError))
    
    init_pid(:max_attempts => 3)
    @pid.send(:quick, :brown)
    @pid.connection_failed(@connection)
    @pid.connection_failed(@connection)
    @pid.timer_action
    @pid.timer_action
  end
end
