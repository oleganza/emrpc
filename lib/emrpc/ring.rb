module EMRPC
=begin

  REPLICATION
  
    Who does replication?
    
    Master schedules replication streams:
      + replication is centralized
      - replicas' existance is not guaranteed.
      - overcomplication (?)
    Primary chunkserver replicates data to secondary chunkservers:
      - every chunkserver must know about other chunkservers
      - 
    Client streams data to all the chunkservers:
      - bandwidth!
      + most simple scheme

  RELIABILITY PRINCIPLES
  
  1. Client should be guaranteed, that data is completely replicated.
    Therefore, it can do replication on its own.
      For optimization reasons, it can delegate some streams to
      other nodes. Say, it sends data to node A and tells it to replicate data
      to node B. A must report finish of both A and B streamings.
  2. Client may connect any node and try to upload the file there.

=end

  module Ring
    
    class Bucket
      attr_accessor :range
      def initialize
        
      end
    end
    
    class Master
      
    end
    
  end
end
