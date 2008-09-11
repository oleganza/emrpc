require File.dirname(__FILE__) + '/spec_helper'

describe Pids, "chat" do
  
  before(:all) do
    
    class Chatter < Fixtures::Person
      include Pid
      attr_accessor :chat, :notices, :log
      def initialize(*args)
        super
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
        p [:chatter, :receive, from, msg]
        @log << msg
      end
      def write(msg)
        @log << msg
        p [:chatter, :write, msg, @chat]
        @chat.write(self, msg)
      end
    end
        
    class Chat
      include Pid
      def initialize
        super
        @chatter = []
      end
      def connected(pid)
        p [:chat, :connected, pid]
        @chatters << pid
      end
      def disconnected(pid)
        p [:chat, :disconnected, pid]
        @chatters.delete(pid)
        broadcast(:notice, "Chatter #{pid.uuid} disconnected!")
      end
      def write(from, text)
        p [:chat, :write, from, text]
        broadcast(:receive, text) {|c| c != from }
      end
      def broadcast(msg, text, &blk)
        p [:chat, :broadcast, @chatters.size, msg, text]
        cs = @chatters
        cs = @chatters.select(&blk) if blk
        cs.each do |c|
          c.send(msg, self, text)
        end
      end
    end
    
    @oleg  = Chatter.new("oleg")
    @olga  = Chatter.new("olga")
    
    @chat_addr = em_addr
    @chat = Chat.new
    @chat.bind(@chat_addr)
    
    @oleg.extend(Module.new{
      def receive(from, text)
        super
        case text
        when /hello!/i
          write "How are you?"
        when /fine/i
          write "Ok then! Cya!"
        when /ciao/i
        else 
          write "I don't understand you"
        end
      end
      def connected(pid)
        p [:oleg, :connected, pid]
        super
        write("Hi!")
      end
    })

    @olga.extend(Module.new{
      def receive(from, text)
        super
        case text
        when /hi!/i
          write "Hello!"
        when /how are you!/i
          write "Fine, thanks!"
        when /cya!/i
          write "Ciao!"
        else 
          write "I don't understand you"
        end
      end
    })
    Thread.new do
      @oleg.connect(@chat_addr)
      @olga.connect(@chat_addr)
    end
  end
  
  it "should produce a conversion" do
    sleep 2
    
    p @oleg.log
    
  end
  
  
    
end
