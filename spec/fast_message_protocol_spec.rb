require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FastMessageProtocol do
  before(:each) do
    @peer_class = Class.new do
      def initialize
        post_init
      end
      def post_init
      end
    end
    @oleganza = Class.new(@peer_class) do
      include FastMessageProtocol
    end
    @yrashk = Class.new(@peer_class) do
      include FastMessageProtocol
    end
    @oleganza.class_eval do
      attr_accessor :messages
      def post_init
        @messages = []
        super
      end
      def receive_fast_message(msg)
        @messages << msg
      end
    end
    @yrashk.class_eval do
      attr_accessor :peer
      def post_init
        @buffer = ""
        super
      end
      def send_data(data)
        @buffer << data
        flush_buffer if @buffer.size > (rand(300) + 1)
      end
      def flush_buffer
        @peer.receive_data(@buffer.dup)
        @buffer = ""
      end
    end
  end
  
  it "should receive all messages" do
    messages = Array.new(1000) {|i| (i*(rand(100)+1)).to_s*(1+rand(100))  }
    oleg = @oleganza.new
    yr = @yrashk.new
    yr.peer = oleg
    messages.each {|m| yr.send_fast_message(m) }
    yr.flush_buffer
    
    oleg.messages.should == messages
  end
  
  it "should handle protocol errors" do
    pending "Add message size limit and specs!"
  end
  
end
