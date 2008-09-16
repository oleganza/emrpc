require File.dirname(__FILE__) + '/spec_helper'

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

