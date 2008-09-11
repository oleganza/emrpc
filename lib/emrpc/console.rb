# Runs eventmachine reactor in a child thread,
# waits while reactor is ready in the current thread.
# Returns child thread.
#
module EventMachine
  def self.run_in_thread(delay = 0.25, &blk)
    blk = proc{} unless blk
    t = Thread.new do
      EventMachine.run(&blk)
    end
    sleep delay
    t
  end
end

module EMRPC
  module Console
    include GemConsole
    help 'n/a yet'
    
    def project_name
      "EMRPC #{::EMRPC::VERSION}"
    end
    
    def setup
      $em_thread ||= EventMachine.run_in_thread(0)
    end
    
  end # Console
end # EMRPC
