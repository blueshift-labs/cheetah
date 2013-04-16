# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cheetah/version"

Gem::Specification.new do |s|
  s.name        = "cheetah"
  s.version     = Cheetah::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Rodriguez", "Wil Chung"]
  s.email       = ["theoperand@gmail.com", "iamwil@gmail.com"]
  s.homepage    = "https://github.com/iamwilhelm/cheetah"
  s.summary     = %q{A simple library for integrating with the CheetahMail API}
  s.description = %q{CheetahMail is an email provider that sends email for you. Interface with them through this library}

  # s.required_rubygems_version = ""
  s.rubyforge_project = "cheetah"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.version       = Cheetah::VERSION

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakeweb'
end
