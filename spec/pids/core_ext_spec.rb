require File.dirname(__FILE__) + '/spec_helper'

describe Object, "#_initialize_pids_recursively_d4d309bd!" do

  describe "without #each method" do
    before(:each) do
      @obj = Object.new
      @obj.freeze
    end
    it "should do nothing when object doesn't respond to #each method" do
      lambda { @obj._initialize_pids_recursively_d4d309bd!(nil) }.should_not raise_error
    end
  end
  
  describe "with #each method" do
    before(:each) do
      @obj = Object.new
      meth = :_initialize_pids_recursively_d4d309bd!
      n = 6
      item = mock("item")
      item.should_receive(meth).exactly(n).times.with(anything)
      class <<@obj
        attr_accessor :item
        def each
          yield(item, item, item)
          yield(item, item)
          yield(item)
        end
      end
      @obj.item = item
    end
    it "should traverse each argument of the #each method's block" do
      @obj._initialize_pids_recursively_d4d309bd!(nil)
    end
  end
end
