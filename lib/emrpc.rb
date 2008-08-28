require 'rubygems'
require 'eventmachine'

$LOAD_PATH.unshift( File.expand_path(File.join(File.dirname(__FILE__))))

require 'emrpc/version'
require 'emrpc/fast_message_protocol'
require 'emrpc/marshal_protocol'
require 'emrpc/server'
require 'emrpc/method_proxy'
require 'emrpc/multithreaded_client'
require 'emrpc/singlethreaded_client'
require 'emrpc/blocking_client'
require 'emrpc/client'
