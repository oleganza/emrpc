spec = Gem::Specification.new do |s|
  s.name = %q{emrpc}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Oleg Andreev"]
  s.date = %q{2008-10-03}
  s.default_executable = %q{emrpc}
  s.description = %q{Efficient RPC library with evented and blocking APIs. In all ways better than DRb.}
  s.email = %q{oleganza@gmail.com}
  s.executables = ["emrpc"]
  s.extra_rdoc_files = ["README", "TODO", "MIT-LICENSE"]
  s.files = ["README", "Rakefile", "TODO", "MIT-LICENSE", "bin/emrpc", "spec/blocking_api", "spec/blocking_api/method_proxy_spec.rb", "spec/blocking_api/multithreaded_client_spec.rb", "spec/blocking_api/scenario_spec.rb", "spec/blocking_api/singlethreaded_client_spec.rb", "spec/blocking_api/spec_helper.rb", "spec/blocking_api_test.rb", "spec/evented_api", "spec/evented_api/connection_mixin_spec.rb", "spec/evented_api/default_callbacks_spec.rb", "spec/evented_api/evented_wrapper_spec.rb", "spec/evented_api/pid_spec.rb", "spec/evented_api/reconnecting_pid_spec.rb", "spec/evented_api/remote_connection_spec.rb", "spec/evented_api/remote_pid_spec.rb", "spec/evented_api/scenario_spec.rb", "spec/evented_api/spec_helper.rb", "spec/evented_api/subscribable_spec.rb", "spec/server_spec.rb", "spec/spec_helper.rb", "spec/util", "spec/util/blank_slate_spec.rb", "spec/util/codec_spec.rb", "spec/util/fast_message_protocol_spec.rb", "spec/util/marshal_protocol_spec.rb", "spec/util/parsed_uri_spec.rb", "spec/util/spec_helper.rb", "lib/emrpc", "lib/emrpc/archive", "lib/emrpc/archive/reference_savior.rb", "lib/emrpc/archive/ring.rb", "lib/emrpc/blocking_api", "lib/emrpc/blocking_api/method_proxy.rb", "lib/emrpc/blocking_api/multithreaded_client.rb", "lib/emrpc/blocking_api/singlethreaded_client.rb", "lib/emrpc/blocking_api.rb", "lib/emrpc/client.rb", "lib/emrpc/console.rb", "lib/emrpc/evented_api", "lib/emrpc/evented_api/connection_mixin.rb", "lib/emrpc/evented_api/debug_connection.rb", "lib/emrpc/evented_api/debug_pid_callbacks.rb", "lib/emrpc/evented_api/default_callbacks.rb", "lib/emrpc/evented_api/evented_wrapper.rb", "lib/emrpc/evented_api/local_connection.rb", "lib/emrpc/evented_api/pid.rb", "lib/emrpc/evented_api/protocol_mapper.rb", "lib/emrpc/evented_api/reconnecting_pid.rb", "lib/emrpc/evented_api/remote_connection.rb", "lib/emrpc/evented_api/remote_pid.rb", "lib/emrpc/evented_api/subscribable.rb", "lib/emrpc/evented_api/timer.rb", "lib/emrpc/evented_api.rb", "lib/emrpc/protocols", "lib/emrpc/protocols/fast_message_protocol.rb", "lib/emrpc/protocols/marshal_protocol.rb", "lib/emrpc/protocols.rb", "lib/emrpc/server.rb", "lib/emrpc/util", "lib/emrpc/util/blank_slate.rb", "lib/emrpc/util/codec.rb", "lib/emrpc/util/combine_modules.rb", "lib/emrpc/util/em2rev.rb", "lib/emrpc/util/em_start_stop_timeouts.rb", "lib/emrpc/util/parsed_uri.rb", "lib/emrpc/util/safe_run.rb", "lib/emrpc/util/timers.rb", "lib/emrpc/util.rb", "lib/emrpc/version.rb", "lib/emrpc.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://oleganza.com/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.4")
  s.requirements = ["You need to install the json (or json_pure), yaml, rack gems to use related features."]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Efficient RPC library with evented and blocking APIs. In all ways better than DRb.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<gem_console>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<gem_console>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<gem_console>, [">= 0"])
  end
end
