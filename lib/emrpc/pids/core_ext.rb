module EMRPC
  module Pids
    #
    # Initializes pids recursively upon any enumerable (responding to #each).
    #
    class ::Object
      def _initialize_pids_recursively_d4d309bd!(host_pid)
        return unless respond_to?(:each)
        each do |*args|
          args.each do |a|
            a._initialize_pids_recursively_d4d309bd!(host_pid)
          end
        end
      end # _initialize_pids_recursively_d4d309bd!
    end # ::Object    
  end # Pids
end # EMRPC
