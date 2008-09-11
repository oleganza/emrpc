require File.dirname(__FILE__) + '/spec_helper'

describe Pids, "chat" do
  
  before(:all) do
    
    class Person < Fixtures::Person
      include Pid
    end
    
    @oleg = Person.new()
    
    
  end
  
  it "should " do
    
  end
  
  
    
end
