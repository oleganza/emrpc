require File.dirname(__FILE__) + '/spec_helper'

describe "encode_b381b571_1ab2_5889_8221_855dbbc76242 on" do
  
  before(:each) do
    @encode_method = :encode_b381b571_1ab2_5889_8221_855dbbc76242
    @dummy_pid = mock("dummy pid")
    @host_pid = mock("host pid", :find_pid => @dummy_pid)
  end
  
  describe Object do
    before(:each) do
      @obj = Object.new
    end
    
    it "should raise error" do
      lambda { @obj.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid) }.should raise_error
    end  
  end
  
  describe "primitive", :shared => true do
    it "should return itself" do
      @obj.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid).should eql(@obj)
    end
  end

  [nil, true, false, "string", 123, 3.725, :symbol].each do |obj|
    describe obj.inspect do
      before(:each) do
        @obj = obj
      end
      it_should_behave_like "primitive"
    end
  end
  
  def encoding_mock(name, n)
    enc = name.upcase.to_sym
    item = mock(name)
    item.stub!(@encode_method).and_return(enc)
    item.should_receive(@encode_method).exactly(n).times.with(@host_pid).and_return do |hpid|
      hpid.should == @host_pid
      enc
    end
    item
  end
  
  describe Array do
    before(:each) do
      item = encoding_mock("item", 6)
      @arr = [item, item, [item, item, [item, [[item]] ]]]
      @encoded = @arr.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
    end
    it "should encode each item recusively" do
      item = :ITEM
      @encoded.should == [item, item, [item, item, [item, [[item]] ]]]
    end
  end
  
  describe Hash do
    before(:each) do
      key   = encoding_mock("key", 3)
      value = encoding_mock("value", 3)
      @hash = { key => value, :key => { key => { "str" => value, key => {"str" => 123, :sym => value } } } }
      @encoded = @hash.encode_b381b571_1ab2_5889_8221_855dbbc76242(@host_pid)
    end
    it "should encode each key and value recusively" do
      key = :KEY
      value = :VALUE
      @encoded.should == { key => value, :key => { key => { "str" => value, key => {"str" => 123, :sym => value } } } }
    end
  end
  
  describe EventedAPI::Pid do
    
  end
end


# describe Object, "#_initialize_pids_recursively_d4d309bd!" do
# 
#   describe "without #each method" do
#     before(:each) do
#       @obj = Object.new
#       @obj.freeze
#     end
#     it "should do nothing when object doesn't respond to #each method" do
#       lambda { @obj._initialize_pids_recursively_d4d309bd!(nil) }.should_not raise_error
#     end
#   end
#   
#   describe "with #each method" do
#     before(:each) do
#       @obj = Object.new
#       meth = :_initialize_pids_recursively_d4d309bd!
#       n = 6
#       item = mock("item")
#       item.should_receive(meth).exactly(n).times.with(anything)
#       class <<@obj
#         attr_accessor :item
#         def each
#           yield(item, item, item)
#           yield(item, item)
#           yield(item)
#         end
#       end
#       @obj.item = item
#     end
#     it "should traverse each argument of the #each method's block" do
#       @obj._initialize_pids_recursively_d4d309bd!(nil)
#     end
#   end
# end

# describe "marshal_dump/marshal_load" do
#   it "should not raise errors" do
#     lambda { Marshal.dump(@rpid) }.should_not raise_error
#     lambda { Marshal.load(Marshal.dump(@rpid)) }.should_not raise_error
#   end
#   it "should dump uuid" do
#     @rpid.marshal_dump.should == @uuid
#   end
#   
#   describe "loaded" do
#     before(:each) do
#       rpid = @cls.allocate
#       rpid.marshal_load(@rpid.marshal_dump)
#       @rpid = rpid
#     end
#     
#     it "should have uuid" do
#       @rpid.uuid.should == @uuid
#     end
#           
#     it "should not have _connection" do
#       @rpid._connection.should be_nil
#     end
#     
#     it_should_behave_like "inspectable"
#     
#     it "should have 'NO CONNECTION' text in inspect" do
#       @rpid.inspect.should =~ /NO CONNECTION/
#     end
#     
#   end # loaded
# end # marshal



# describe Pid, "#_initialize_pids_recursively_d4d309bd" do
#   before(:each) do
#     @options = {:uuid => @uuid}
#     @hosted_rpid = mock('Hosted remote pid', 
#                         :options => @options, 
#                         :_connection => @connection)
#     @host_pid = mock('Host pid')
#     @host_pid.stub!(:find_pid)
#     @host_pid.should_receive(:find_pid).once.with(@uuid).and_return(@hosted_rpid)
#     @rpid._initialize_pids_recursively_d4d309bd!(@host_pid)
#   end
#   
#   it "should set _connection" do
#     @rpid._connection.should == @connection
#   end
#   
#   it "should keep uuid" do
#     @rpid.uuid.should == @uuid
#   end
# end # _initialize_pids_recursively_d4d309bd!

