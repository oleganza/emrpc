require File.dirname(__FILE__) + '/spec_helper'

describe Subscribable do
  extend MockDescribe
  
  before(:all) do
    @cls = Class.new { include Subscribable }
    @cafe = @cls.new
  end

  def client_mock(name)
    m = mock(name)
    m.stub!(:send)
    m
  end
  
  mock_describe "subscribed client" do
    oleg = client_mock("Oleg in cafe")
    oleg.should_receive(:send).once.with(:on_open, :arg).ordered
    oleg.should_receive(:send).once.with(:on_close).ordered
    andrey = client_mock("Andrey in cafe")
    andrey.should_receive(:send).once.with(:on_close).ordered
    
    @cafe.subscribe(:open,  oleg, :on_open)
    @cafe.subscribe(:close, oleg, :on_close)
    @cafe.subscribe(:close, andrey, :on_close)
    
    @cafe.notify_subscribers(:open, :arg)
    @cafe.notify_subscribers(:close)
  end

  mock_describe "unsubscribed client from event" do
    oleg = client_mock("Oleg in cafe")
    oleg.should_not_receive(:send).with(:on_open, :arg)
    oleg.should_receive(:send).with(:on_close).ordered
    andrey = client_mock("Andrey in cafe")
    andrey.should_receive(:send).with(:on_close).ordered
    
    @cafe.subscribe(:open,  oleg, :on_open)
    @cafe.subscribe(:close, oleg, :on_close)
    @cafe.subscribe(:close, andrey, :on_close)
    
    @cafe.unsubscribe(:open, oleg)
    
    @cafe.notify_subscribers(:open, :arg)
    @cafe.notify_subscribers(:close)
  end
  
  
  %{
    TODO: more scenarios with special DSL
  }
end
