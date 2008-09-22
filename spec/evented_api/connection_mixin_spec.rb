require File.dirname(__FILE__) + '/spec_helper'

describe ConnectionMixin do
  
  before(:each) do
    @mod = ConnectionMixin
  end
  
  [
    :local_pid,
    :remote_pid,
    :connected_callback,
    :disconnected_callback
  ].each do |a|
    it "should have #{a} accessor" do
      ConnectionMixin.instance_method(a).should_not be_nil
      ConnectionMixin.instance_method(:"#{a}=").should_not be_nil
    end
  end

  describe "instance" do
    before(:each) do
      @obj = Class.new{ include ConnectionMixin }.new      
    end
    
    it "should have default connected_callback" do
      @obj.connected_callback.should == :connected
    end
    
    it "should have default disconnected_callback" do
      @obj.disconnected_callback.should == :disconnected
    end    
  end
end
