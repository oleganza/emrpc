require File.dirname(__FILE__) + '/spec_helper'

describe "Chat" do
  
  before(:all) do
    
    class Chatterer < Fixtures::Person
      include Pid
      attr_accessor :chat, :notices, :log
      def initialize(*args)
        super(*args)
        @notices = []
        @log = []
      end
      def connected(pid)
        @chat = pid
      end
      def notice(msg)
        @notices << msg
      end
      def receive(from, msg)
        @log << [from, msg]
      end
      def write(msg)
        @log << [@name, msg]
        @chat.write(self, @name, msg)
      end
      def pid_class_name
        self.class.name
      end
    end
        
    class Chat
      include Pid
      def initialize
        super
        @chatterers = []
      end
      def connected(pid)
        @chatterers << pid
      end
      def disconnected(pid)
        @chatterers.delete(pid)
        broadcast(:notice, self, "Chatterer #{pid.uuid} disconnected!")
      end
      def write(from, name, text)
        broadcast(:receive, name, text) {|c| c != from }
      end
      def broadcast(msg, *args, &blk)
        cs = @chatterers
        cs = cs.select(&blk) if blk
        cs.each do |c|
          c.send(msg, *args)
        end
      end
      def pid_class_name
        self.class.name
      end
    end
    
    class Oleg < Chatterer
      def initialize
        super(:name => "oleg")
      end
      def receive(from, text)
        super
        case text
        when /hello!/i
          write "How are you?"
        when /fine/i
          write "Ok then! Cya!"
        when /ciao/i
        else 
          raise "I don't understand you"
        end
      end
      def connected(pid)
        super
        write("Hi!")
      end
    end
    
    class Olga < Chatterer
      def initialize
        super(:name => "olga")
      end
      def receive(from, text)
        super
        case text
        when /hi!/i
          write "Hello!"
        when /how are you/i
          write "Fine, thanks!"
        when /cya!/i
          write "Ciao!"
        else 
          raise "I don't understand you"
        end
      end
    end
    
    @oleg  = Oleg.new
    @olga  = Olga.new
    
    @oleg.method(:marshal_dump)
    
    @chat_addr = em_addr
    @chat = Chat.new

    @chat.bind(@chat_addr)
        
    lambda { Marshal.dump(@oleg) }.should_not raise_error
    lambda { Marshal.dump(@olga) }.should_not raise_error
    
    Thread.new do
      @oleg.connect(@chat_addr)
      @olga.connect(@chat_addr)
    end
  end
  
  it "should produce a conversation" do
    sleep 0.5
    
    @oleg.log.should == [
      ["oleg", "Hi!"],
      ["olga", "Hello!"],
      ["oleg", "How are you?"],
      ["olga", "Fine, thanks!"],
      ["oleg", "Ok then! Cya!"],
      ["olga", "Ciao!"]
    ]
    
    @oleg.log.should == @olga.log
  end
  
  
    
end
