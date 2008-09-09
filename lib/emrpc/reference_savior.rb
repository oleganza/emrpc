module EMRPC
  
  class StaleReference < StandardError; end
  
  class ReferenceSavior
    attr_accessor :timeout
    # :timeout - specifies a time interval for keeping a reference to a value
    def initialize(options)
      @timeout        = options[:timeout] || 60
      @timer          = options[:timer] || Timers::EVENTED
      @timeout_thread = @timer.call(@timeout, method(:swap_pages))
      # We keep two previous pages to ensure, that the value lives for at least +timeout+ seconds.
      @page1 = new_page
      @page2 = new_page
    end
    
    def set(val)
      oid = val.object_id
      ping(oid, val)
      MethodProxy.new(Wrapper.new(oid))
    end
    
    def get(oid)
      oid = oid.to_i
      val = @page1[oid] || @page2[oid]
      raise StaleReference.new("Object id #{oid} was not found in a ReferenceSavior cache. It could have been garbage collected after #{@timeout} sec.") unless val
      ping(oid, val)
      val
    end
    
    def ping(oid, val)
      @page1[oid] = val
    end
    
    # @page2 disappears and will be garbage collected.
    # @page1 is copied to @page2 for another @timeout seconds
    # and is replaced by a brand new cache page.
    def swap_pages
      @page2 = @page1
      @page1 = new_page
    end

    def new_page
      Hash.new
    end
  end
end
  