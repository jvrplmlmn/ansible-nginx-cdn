# encoding: utf-8
#
# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe user('www-data') do
  it { should exist }
end

describe host('localhost', port: 80, proto: 'tcp') do
  it { should be_reachable }
end

describe port(80) do
  it { should be_listening}
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
end

describe file('/etc/nginx/conf.d/upstream.conf') do
  it { should exist }
end

describe file('/etc/nginx/sites-enabled/default') do
  it { should_not exist }
end

describe file('/etc/nginx/sites-enabled/cabify-http.conf') do
  it { should exist }
  it { should be_symlink }
  it { should be_linked_to '/etc/nginx/sites-available/cabify-http.conf' }
end
