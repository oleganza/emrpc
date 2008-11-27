require 'uri'
require 'rubygems'
require 'eventmachine'

# add current dir to the load path
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

$DEBUG ||= ENV['DEBUG']

require 'emrpc/version'
require 'emrpc/util'
require 'emrpc/protocols'
require 'emrpc/evented_api'
require 'emrpc/blocking_api'
require 'emrpc/server'
require 'emrpc/client'
