$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'emrpc'
include EMRPC

PORT = 4567

if child = fork # parent
  module ServerProtocol
    include FastMessageProtocol
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
  EM::safe_run(:bg) { } 
  
  require 'thread'
  
  module ClientProtocol
    include FastMessageProtocol
    
    def connection_completed
      msg = "Hello!"
      puts "connection_completed>> sending #{msg.inspect}"
      
      result = blocking_send_message(msg)
      puts "Received: #{result}"
    end
    
    def blocking_send_message(msg)
      puts "blocking_send_message>> Thread.current == #{Thread.current}"
      @msg = Queue.new
      send_message(msg)
      #@msg.shift
    end
    
    def receive_message(data)
      puts "receive_message>> Thread.current == #{Thread.current}"
      puts "receive_message>> data == #{data.inspect}"
      @msg.push(data)
    end
    
    def unbind
      puts "Client disconnected!"
      exit
    end
  end
  
  sleep 1
  
  conn = EM.connect("localhost", PORT, ClientProtocol)
  
  sleep 5
  
  puts "End of client program."
end

puts "Very end."
