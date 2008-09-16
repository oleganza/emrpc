class ::String
  def _initialize_pids_recursively_d4d309bd!(host_pid)
    STDERR.puts "DEPRECATED"
  end
  
  def parsed_uri
    URI.parse(self)
  end
end

class ::URI::Generic
  def parsed_uri
    self
  end
end
