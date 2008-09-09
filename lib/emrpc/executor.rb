module EMRPC
  module Executor
    # TODO: yield support
    def execute
      begin
        r = yield
        return_value(r)
        #[:return, encode_value(r)]
      rescue Exception => e
        raise_value(e)
        #[:raise, encode_value(e)]
      end
    end
  end
end
