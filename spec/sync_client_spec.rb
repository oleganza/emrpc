require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# describe "Sync client" do
#   
#   # Run server
#   before(:all) do
#     @em_thread = EM.run_in_thread do
#       paris = Fixtures::Paris.new(4, :cafes => ["quai-quai", "2 moulins"])
#       EMRPC::Server.new(:host => EM_HOST, :port => EM_PORT, :object => paris).run
#     end
#   end
#   after(:all) do
#     begin
#       EM.stop_event_loop
#       @em_thread.kill
#     rescue => e
#       puts "Exception after specs:"
#       puts e.inspect
#     end
#   end
#   
#   # Run client
#   before(:each) do
#     @paris  = EMRPC::Client.new(:host => EM_HOST, :port => EM_PORT)
#     # wrong port
#     @berlin = EMRPC::Client.new(:host => EM_HOST, :port => EM_PORT + 1)
#     # wrong host
#     @prague = EMRPC::Client.new(:host => "192.254.254.254", :port => EM_PORT)
#   end
#   
#   it "should get serialized data" do
#     @paris.options.should == { :cafes => ["quai-quai", "2 moulins"] }
#   end
#   
#   it "should issue connection error" do
#     lambda { @berlin.options }.should raise_error(EMRPC::ConnectionError)
#   end
#   
# end
