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
      @inbox = Queue.new
      @outbox = Queue.new
      @consumer_thread = Thread.new(self) do |conn|
        begin
          while 1
            msg = @outbox.shift
            puts "Client@consumer_thread: msg = #{msg.inspect}"
            conn.send_message(msg)
          end
        rescue => e
          puts "Client@consumer_thread: EXCEPTION!"
          puts e
        end
      end
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
      @inbox.push(data)
    end
    
    def unbind
      puts "Client#unbind"
      exit
    end
  end
  
  sleep 1
  
  conn = EM.connect("localhost", PORT, ClientProtocol)
  
  result = conn.blocking_send_message("Hello!!!")
  puts "Got result: #{result}"
  
  
  sleep 5
  
  puts "End of client program."
end

puts "Very end."
