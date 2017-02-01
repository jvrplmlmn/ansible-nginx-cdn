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

nginx_user = 'www-data'

describe user(nginx_user) do
  it { should exist }
end

[
  80,
  443
].each do |nginx_port|
  describe host('localhost', port: nginx_port, proto: 'tcp') do
    it { should be_reachable }
  end

  describe port(nginx_port) do
    it { should be_listening}
  end
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
end

[
  'ssl',
  'upstream'
].each do |nginx_conf_file|
  describe file("/etc/nginx/conf.d/#{nginx_conf_file}.conf") do
    it { should exist }
  end
end

describe file('/etc/nginx/sites-enabled/default') do
  it { should_not exist }
end

[
  'cabify-http',
  'cabify-https'
].each do |site|
  describe file("/etc/nginx/sites-enabled/#{site}.conf") do
    it { should exist }
    it { should be_symlink }
    it { should be_linked_to "/etc/nginx/sites-available/#{site}.conf" }
  end
end
