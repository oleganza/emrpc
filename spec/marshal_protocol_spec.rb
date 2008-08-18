require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'json'
require 'yaml'

def create_marshal_protocol_instance(interface)
  mod = MarshalProtocol.new(interface)
  
  spec_module = Module.new do
    def send_message(data)
      data
    end
    def receive_marshalled_message(data)
      data
    end
    def rescue_marshal_error(e)
      [:error, e]
    end
  end
  
  Class.new do
    include mod
    include spec_module
  end.new
end

describe "Generic MarshalProtocol", :shared => true do
  it "should pass data in and out" do
    encoded = @instance.send_marshalled_message(@msg)
    decoded = @instance.receive_message(encoded)
    decoded.should == @msg
  end
  
  it "should report error when format is wrong" do
    encoded = @instance.send_marshalled_message(@msg)
    decoded = @instance.receive_message("blah-blah"+encoded)
    decoded.first.should == :error
  end
end

[Marshal, JSON, YAML].each do |interface|
  describe MarshalProtocol, "with #{interface}" do
    before(:each) do
      # FIXME: fixture containing 3.1415 may cause floating point issues.
      @msg = ["Hello", {"a" => "b", "arr" => [true, false, nil]}, 1, 3.1415]
      @instance = create_marshal_protocol_instance(interface)
    end
    it_should_behave_like "Generic MarshalProtocol"
  end
end
