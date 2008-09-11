require 'rubygems'
require 'eventmachine'

# add current dir to the load path
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

$DEBUG ||= ENV['DEBUG']

require 'emrpc/util'
require 'emrpc/em_start_stop_timeouts'
require 'emrpc/version'
require 'emrpc/safe_run'
require 'emrpc/combine_modules'
require 'emrpc/fast_message_protocol'
require 'emrpc/marshal_protocol'
# FIXME
# require 'emrpc/server'
# require 'emrpc/method_proxy'
# require 'emrpc/multithreaded_client'
# require 'emrpc/singlethreaded_client'
# require 'emrpc/blocking_client'
# require 'emrpc/client'
require 'emrpc/pids'