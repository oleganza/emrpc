require 'rubygems'
require 'eventmachine'

# add current dir to the load path
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

$DEBUG ||= ENV['DEBUG']

require 'emrpc/version'
require 'emrpc/util'
require 'emrpc/protocols'
require 'emrpc/pids'
require 'emrpc/blocking_client'
require 'emrpc/multithreaded_client'
require 'emrpc/method_proxy'

# FIXME
# require 'emrpc/server'
# require 'emrpc/method_proxy'
# require 'emrpc/singlethreaded_client'
# require 'emrpc/blocking_client'
# require 'emrpc/client'
