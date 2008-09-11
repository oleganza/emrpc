module EMRPC
  
  # const_missing shit is only for ommiting parentheses 
  if defined?(self.const_missing)
    class <<self
      alias_method :__1234_const_missing, :const_missing
    end
  else
    def self.__1234_const_missing(c); end
  end

  def self.const_missing(c)
    return BlankSlate() if c == :BlankSlate
    __1234_const_missing(c)
  end
  
  # We cannot define a static class since new methods can be added to the Object 
  # in the runtime. Thus, we create a blank slate class every time user needs it, regardless
  # what methods vere added to the ruby core before.
  def self.BlankSlate
    Class.new do
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    end
  end
end
