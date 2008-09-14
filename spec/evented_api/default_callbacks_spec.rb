require File.dirname(__FILE__) + '/spec_helper'

describe DefaultCallbacks do
  
  before(:each) do
    @mod = DefaultCallbacks
  end
  
  [ 
    [:connected,         1],
    [:disconnected,      1],
    [:connecting_failed, 1],
    [:on_return,         2],
    [:on_raise,          2],
    [:handshake_failed,  2]
  ].each do |(meth, arity)|
    
    a = arity == 1 ? 'one argument' : "#{arity} arguments"
    
    it "should have instance method ##{meth} with #{a}" do
      lambda{ @mod.instance_method(meth) }.should_not raise_error
      @mod.instance_method(meth).arity.should == arity
    end
    
  end
end
