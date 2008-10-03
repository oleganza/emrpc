module EMRPC
  # Enables subscribing and unsubscribing using 
  # * #subscribe(:event_name, rcvr, :callback)
  # * #unsubscribe(:event_name, rcvr[, :callback]) (if no callback is defined, all callbacks for the current pid are removed)
  # * #notify_subscribers(:event_name)
  # 
  module Subscribable
    def initialize(*args, &blk)
      super(*args, &blk)
      @subscriptions = Hash.new # event_name -> array of [pid, callback]
    end
    
    # Subscribes +pid+ to event +event_name+ with callback +callback_name+
    #
    def subscribe(event_name, pid, callback_name)
      @subscriptions[event_name] ||= Array.new
      @subscriptions[event_name] << [pid, callback_name]
      self
    end
    
    # Depending on the arguments passed:
    # * unsubscribe(:event, pid, :on_event) -> unsubscribes the callback for the specified pid and event
    # * unsubscribe(:event, pid)            -> unsubscribes all callbacks for the pid and the event
    # * unsubscribe(:event)                 -> unsubscribes all pids and callbacks for the event
    # * unsubscribe                         -> unsubscribes all pids and callbacks for all events
    # * unsubscribe(:all, pid)              -> unsubscribes pid from all events
    # * unsubscribe(:all, pid, :on_event)   -> unsubscribes pid's :on_event callback from all events
    #
    def unsubscribe(event_name = nil, pid = nil, callback_name = nil)
      if !event_name || event_name == :all
        @subscriptions.each do |event, subscriptions|
          unsubscribe(event, pid, callback_name)
        end
      else
        subscriptions = @subscriptions[event_name] or return self
        subscriptions.delete_if do |pair|
          pd, cb = pair
          (pd == pid || !pid) && (cb == callback_name || !callback_name)
        end
      end
      self
    end
    
    # Sends callback messages to all subscribed pids.
    # If event is not registered, returns 0.
    # Otherwise returns number of notifications.
    def notify_subscribers(event_name, *args, &blk)
      subscriptions = @subscriptions[event_name] or return 0
      subscriptions.each do |(pid, cbk)|
        pid.send(cbk, *args, &blk)
      end
      subscriptions.size
    end
    
  end # Subscriptions
end # EMRPC
