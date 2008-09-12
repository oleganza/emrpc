require File.dirname(__FILE__) + '/spec_helper'

describe EventedWrapper, "callback" do
  
  before(:each) do
    @obj = Class.new do
      def sum(a,b)
        a + b
      end
      def count!
        @c ||= 0
        @c += 1
      end
      def raise_string
        raise "some error"
      end
    end.new
    @pid = EventedWrapper.new(:backend => @obj)
    @sender = mock("sender", :on_return => nil, :on_raise => nil)
  end
  
  describe "#on_return" do
    before(:each) do
      @sender.should_receive(:on_return).once.with(@pid, 23).ordered
      @sender.should_receive(:on_return).once.with(@pid, 42).ordered
      @sender.should_receive(:on_return).once.with(@pid, 1).ordered
      @sender.should_receive(:on_return).once.with(@pid, 2).ordered
      @sender.should_receive(:on_return).once.with(@pid, 3).ordered
      @pid.send(@sender, :sum, 11,  12)
      @pid.send(@sender, :sum, -40, 82)
      @pid.send(@sender, :count!)
      @pid.send(@sender, :count!)
      @pid.send(@sender, :count!)
    end
    it "should verify mock expectations" do
    end
  end
  
  describe "#on_raise" do
    before(:each) do
      @sender.should_receive(:on_raise).once.with(@pid, an_instance_of(RuntimeError)).ordered
      @sender.should_receive(:on_raise).once.with(@pid, an_instance_of(NoMethodError)).ordered
      @pid.send(@sender, :raise_string)
      @pid.send(@sender, :no_method)
    end
    it "should verify mock expectations" do
    end
  end
  
end
