module EventMachine
  # Allows to safely run EM in foreground or in a background
  # regardless of is running already or not.
  #
  # Foreground: EM::safe_run { ... }
  # Background: EM::safe_run(:bg) { ... }
  def EventMachine::safe_run(background = nil, &block)
    if EventMachine::reactor_running?
      # Attention: here we loose the ability to catch
      # immediate connection errors.
      EventMachine::next_tick(&block)
      sleep if $em_reactor_thread && !background
    else
      if background
        $em_reactor_thread = Thread.new do
          EventMachine::run(&block)
        end
      else
        EventMachine::run(&block)
      end
    end
  end
end
