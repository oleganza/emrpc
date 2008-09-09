module EMRPC
  module Util
    # Combines several modules into a single one within a new module.
    def combine_modules(*modules)
      Module.new do
        modules.each {|m| include m }
      end
    end
    extend self
  end
end
