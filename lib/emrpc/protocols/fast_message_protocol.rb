module EMRPC
  # Receives data with a 4-byte integer size prefix (network byte order).
  # Underlying protocol must implement #send_data and invoke #receive_data.
  # User's protocol must call #send_message and listen to #receive_message callback.
  module FastMessageProtocol
    def post_init
      @fmp_size = 0         # if 0, we're waiting for a new message,
                            # else - accumulating data.
      @fmp_size_chunk = ""  # we store a part of size chunk here
      @fmp_data = ""
      super
    end

    LENGTH_FORMAT = "N".freeze
    LENGTH_FORMAT_LENGTH = 4
    
    def send_message(data)
      size = data.size
      packed_size = [size].pack(LENGTH_FORMAT)
      send_data packed_size
      send_data data
    end

    def receive_data(next_chunk)
      while true # helps fight deep recursion when receiving many messages in a single buffer.
        data = next_chunk
        # accumulate data
        if @fmp_size > 0
          left = @fmp_size - @fmp_data.size
          now  = data.size
          log { "Need more #{left} bytes, got #{now} for now." }

          if left > now
            @fmp_data << data
            break
          elsif left == now
            @fmp_data << data
            data = @fmp_data
            @fmp_data = ""
            @fmp_size = 0
            @fmp_size_chunk = ""
            receive_message(data)
            break
          else
            # Received more, than expected.
            # 1. Forward expected part
            # 2. Put unexpected part into receive_data
            @fmp_data << data[0, left]
            next_chunk = data[left, now]
            data = @fmp_data
            @fmp_data = ""
            @fmp_size = 0
            @fmp_size_chunk = ""
            log { "Returning #{data.size} bytes (#{data[0..32]})"  }
            receive_message(data)
            # (see while true: processing next chunk without recursive calls)
          end

        # get message size prefix
        else
          left = LENGTH_FORMAT_LENGTH - @fmp_size_chunk.size
          now  = data.size
          log { "Need more #{left} bytes for size_chunk, got #{now} for now." }

          if left > now
            @fmp_size_chunk << data
            break
          elsif left == now
            @fmp_size_chunk << data
            @fmp_size = @fmp_size_chunk.unpack(LENGTH_FORMAT)[0]
            log { "Ready to receive #{@fmp_size} bytes."}
            break
          else
            # Received more, than expected.
            # 1. Pick only expected part for length
            # 2. Pass unexpected part into receive_data
            @fmp_size_chunk << data[0, left]
            next_chunk = data[left, now]
            @fmp_size = @fmp_size_chunk.unpack(LENGTH_FORMAT)[0]
            log { "Ready to receive #{@fmp_size} bytes."}
            # (see while true) receive_data(next_chunk) # process next chunk
          end # if
        end # if 
      end # while true
    end # def receive_data
    
    def err
      STDERR.write("FastMessageProtocol: #{yield}\n")
    end
    def log
      puts("FastMessageProtocol: #{yield}")
    end
    # Switch logging off when not in debug mode.
    unless ($DEBUG || ENV['DEBUG']) && !($NO_FMP_DEBUG || ENV['NO_FMP_DEBUG'])
      def log
      end
    end
  end # module FastMessageProtocol
end # EMRPC
