$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'emrpc'
include EMRPC

PORT = 4567
$DEBUG = 1

if child = fork # parent
  module ServerProtocol
    include FastMessageProtocol
    def receive_data(data)
      puts "Server: receive_data -> #{data.inspect}"
      super(data)
    end
    def receive_message(data)
      puts "Server: sending #{data.inspect} back..."
      send_message("Re: #{data}")
    end
  end
  
  EM.run do
    EM.start_server("0.0.0.0", PORT, ServerProtocol) do |conn|
      puts "Server: connection established: #{conn}"
    end
  end
  
  puts "End of server event loop."
  
  Process.waitpid(child)
  
  puts "End of server program."
  
else # child
  
  EM::safe_run(:bg) do 
  end

  require 'thread'
  
  module ClientProtocol
    include FastMessageProtocol
    
    def post_init
      super
      puts "Client: post_init"
      @inbox = Queue.new
      @outbox = Queue.new
      @consumer_thread = Thread.new(self) do |conn|
        begin
          while 1
            msg = @outbox.shift
            puts "Client@consumer_thread: msg = #{msg.inspect}"
            EM.next_tick {
              puts "Tick!"
              conn.send_message(msg)
            }
            puts "Client@consumer_thread: after send"
          end
        rescue => e
          puts "Client@consumer_thread: EXCEPTION!"
          puts e
        end
      end
    end
    
    def start(mbox)
      @mbox = mbox
      msg = "Hello!"
      puts "Client#connection_completed>> sending #{msg.inspect}"
      
      non_blocking_send_message(msg)
      
      #result = blocking_send_message(msg)
      #puts "Client#received: #{result}"
    end
    
    def blocking_send_message(msg)
      puts "Client#blocking_send_message>> Thread.current == #{Thread.current}"
      @outbox.push(msg)
      @inbox.pop
    end
    
    def non_blocking_send_message(msg)
      puts "Client#non_blocking_send_message>> Thread.current == #{Thread.current}"
      send_message(msg)
    end
    
    def receive_message(data)
      puts "Client#receive_message>> Thread.current == #{Thread.current}"
      puts "Client#receive_message>> data == #{data.inspect}"
      @mbox.push(data)
    end
    
    def unbind
      puts "Client#unbind"
      exit
    end
  end
  
  sleep 1
  
  conn = EM.connect("localhost", PORT, ClientProtocol)
  
  sleep 1
  
  @inbox = Queue.new
  @outbox = Queue.new
  
  @acceptor = Thread.new do
    while 1
      args = @outbox.pop
      conn.start(@inbox)
    end
  end
  
  @outbox.push 1
  result = @inbox.pop
  puts "Got result: #{result}"
  
  
  sleep 5
  
  puts "End of client program."
end

puts "Very end."
