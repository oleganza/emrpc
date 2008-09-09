require File.dirname(__FILE__) + '/../spec_helper'

describe BlankSlate do  
  it "should have only __id__ and __send__ instance methods" do
    BlankSlate.instance_methods.sort.should == %w[__id__ __send__]
  end
end
