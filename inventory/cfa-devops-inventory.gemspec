# frozen_string_literal: true

require_relative 'lib/cfa_devops/inventory/version'

Gem::Specification.new do |s|
  s.name        = 'cfa-devops-inventory'
  s.version     = CfaDevops::Inventory::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Code for America DevOps Inventory'
  s.description = 'Inventory collectors for Code for America DevOps teams.'
  s.authors     = ['Code for America']
  s.email       = 'infra@codeforamerica.org'
  s.files       = Dir['lib/**/*'] + Dir['Gemfile*'] + ['Rakefile']
  s.homepage    = 'https://codeforamerica.org'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/codeforamerica/devops-pipelines/issues',
    'homepage_uri' => s.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/codeforamerica/devops-pipelines'
  }

  s.required_ruby_version = '>= 4.0'

  s.add_dependency 'base64', '~> 0.3'
  s.add_dependency 'configsl', '~> 1.0'
  s.add_dependency 'csv', '~> 3.3'
  s.add_dependency 'faraday', '~> 2.15'
  s.add_dependency 'thor', '~> 1.5'
end
