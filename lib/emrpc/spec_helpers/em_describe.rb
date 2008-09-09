module Spec
  module Example
    module ExampleGroupMethods
      def em_describe(*args, &blk)
        describe(*args) do
          before(:all) do 
            $em_thread ||= EventMachine.run_in_thread
          end
          after(:all) do
          end
          class<<self; self; end.send(:module_eval, blk)
        end
      end
    end
  end
end
