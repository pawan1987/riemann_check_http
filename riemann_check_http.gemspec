# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riemann_check_http/version'
require 'riemann_check_http/net_http.rb'
require 'riemann_check_http/riemann.rb'

Gem::Specification.new do |spec|
  spec.name          = "riemann_check_http"
  spec.version       = RiemannCheckHttp::VERSION
  spec.authors       = ["pawan pandey"]
  spec.email         = ["pandey.p1987@gmail.com"]

  spec.summary       = %q{http health check plugin for riemann}
  spec.description   = %q{Monitor the http url for status code and send the status to riemann}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency "riemann-client", "~>0.2.5"
end
