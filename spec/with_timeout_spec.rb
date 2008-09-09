require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
  
describe WithTimeout, "with fast backend" do
  
  before(:each) do
    @backend_cls = Class.new do
      attr_accessor :object
      def send_from(callback, *args, &blk)
        begin 
          r = @object.send(args, &blk)
          callback.on_return(r)
        rescue Exception => e
          callback.on_raise(e)
        end
      end
    end
    
    # create a subclass to put WithTimeout in front of the default methods.
    @backend_cls = Class.new(@backend_cls) 
    
    @backend_cls.send(:include, WithTimeout)
    @backend = @backend_cls.new(:timeout => 1, :timer => Timers::THREADED)
    @backend.object = Paris.new
  end
  
  it "should not raise timeout exception" do
    
  end
end
