require File.dirname(__FILE__) + '/spec_helper'

describe Pids, "chat" do
  
  before(:all) do
    
    class Chatter < Fixtures::Person
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
        #p [:chatter, :receive, from, msg]
        @log << [from, msg]
      end
      def write(msg)
        @log << [@name, msg]
        @chat.write(self, @name, msg)
      end
    end
        
    class Chat
      include Pid
      def initialize
        super
        @chatters = []
      end
      def connected(pid)
        #p [:chat, :connected, pid]
        @chatters << pid
      end
      def disconnected(pid)
        #p [:chat, :disconnected, pid]
        @chatters.delete(pid)
        broadcast(:notice, self, "Chatter #{pid.uuid} disconnected!")
      end
      def write(from, name, text)
        #p [:chat, :write, from, text]
        broadcast(:receive, name, text) {|c| c != from }
      end
      def broadcast(msg, *args, &blk)
        #p [:chat, :broadcast, @chatters.size, msg, text]
        cs = @chatters
        cs = @chatters.select(&blk) if blk
        cs.each do |c|
          c.send(msg, *args)
        end
      end
    end
    
    class Oleg < Chatter
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
        #p [:oleg, :connected, pid]
        super
        write("Hi!")
      end
    end
    
    class Olga < Chatter
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
    
    #p [:@oleg, @oleg]
    #p [:@olga, @olga]
    
    @chat_addr = em_addr
    @chat = Chat.new
    #p [:@chat, @chat]
    @chat.bind(@chat_addr)
        
    lambda { Marshal.dump(@oleg) }.should_not raise_error
    lambda { Marshal.dump(@olga) }.should_not raise_error
    
    Thread.new do
      @oleg.connect(@chat_addr)
      @olga.connect(@chat_addr)
    end
  end
  
  it "should produce a conversion" do
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
