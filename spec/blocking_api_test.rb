$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'emrpc'
include EMRPC

module PrefixedOutput
  def puts(line)
    super("#{pfx}#{line}")
  end
  def print(line)
    super("#{pfx}#{line}")
  end
  def p(line)
    puts("#{line.inspect}")
  end
  def pfx
    "#{Process.pid}: "
  end
end

module Kernel
  include PrefixedOutput
end

class Object
  include PrefixedOutput
end

extend PrefixedOutput

# STDOUT.extend(PrefixedOutput)
# STDERR.extend(PrefixedOutput)
# $stdout.extend(PrefixedOutput)
# $stderr.extend(PrefixedOutput)

if child = fork
  
  puts "In a parent with child #{child}"
  
  p [Object.new, 1]
  
  Process.waitpid(child)
  
else
  
  puts "In a child #{Process.pid}"
  sleep 1
  
end

