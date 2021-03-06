nodespec
========

RSpec style tests for multiple nodes/server instances with support for provisioning with puppet, chef, ansible.

- [**Read the documentation**](https://github.com/smontanari/nodespec/wiki)

## Nodespec vs Serverspec
[Serverspec](http://serverspec.org) is a popular gem that allows you to write rspec tests to validate your servers/hosts configuration.

Nodespec is not an alternative to Serverspec, rather it's build on top of it, so you can still leverage all of its features while enjoying some extra goodies.

#### What's different
Nodespec overcomes some of the limitations of Serverspec, such as mixed OS'/backends support (Windows/WinRM and UN*X/SSH) and easy configurability and connectivity to your target hosts.

Nodespec enables a declarative way of configuring your remote connections, be it simple Ssh, a Vagrant box, or an Amazon EC2 instance.

Nodespec adds support for issuing provisioning commands (through Puppet, Chef or Ansible) to your target hosts, that could be incorporated as part of your test setup.

Below is a quick summary of the main features of nodespec. Refer to the [wiki](https://github.com/smontanari/nodespec/wiki) for more details and examples.

## Nodespec features

#### Hostname declared or inferred in specs

In serverspec you would typically have to create folders named after your target servers, whereas in nodespec you can simply declare your target server names as your spec example group:

```ruby
describe "test.example1.com" do
  ...
end
```
```ruby
describe "test.example2.com" do
  ...
end
```
#### Easy connection configuration
No more ruby code and create programmatically SSH objects, just a quick and easy inline (or file/yaml based) configuration:

```ruby
describe "test.example.com", nodespec: {
    'adapter' => 'ssh',
    'user'    => 'testuser',
    'keys'    => 'path/to/key'
  } do
...
end
```
#### Support connections to Windows & Un*x servers
One of the major limitations of serverspec is that you have to make a hard decision beforehand on which OS/backend you are targeting with your tests. In particular you have to include specific specinfra modules in your `spec_helper` depending on whether you're connecting to Un\*x or Windows machines, using ssh or winrm. Practically it is not possible to test different OSs/backends as part of the same spec run, unless you start hacking some conditional logic in your spec_helper, that is.

With Nodespec that problem is resolved and you can easily connect and test multiple OS and multiple backends in the same rspec run by simply specifying the desired adapter and connection properties for your target host. For instance, to connect to a Windows/WinRM box:
```ruby
describe "test.windows-example.com", nodespec: {
    'adapter'         => 'winrm',
    'user'            => 'testuser',
    'pass'            => 'somepass',
    'transport'       => 'ssl'
  	'basic_auth_only' => true
  } do
...
end
```
## Provisioning (aka TDD your infrastructure)
Nodespec provides support for running Chef, Puppet, Ansible or shellscript commands as part of your tests, e.g.:

#### Chef
```ruby
describe "server1", nodespec: {'adapter' => 'vagrant'} do
  before :all do
    provision_node_with_chef do
      set_cookbook_paths '/vshared/src/cookbooks'
	  set_attributes demo: {crontab: {user: 'peter'}}
      chef_client_runlist 'demo::folders', 'demo::crontab'
    end
  end
...
end
```

#### Puppet
```ruby
describe "test.server", nodespec: {'adapter' => 'ssh'} do
  before :all do
    provision_node_with_puppet do
      set_modulepaths '/vshared/src/modules'
      set_hieradata('users' => {'roger' => {'uid' => 5801}, 'peter' => {'uid' => 5802}})
      puppet_apply_execute "include demo::wheel_users"
    end
  end
...
end
```

#### Ansible
```ruby
describe "i-8f5e74r9", nodespec: {'adapter' => 'aws_ec2'} do
  before :all do
    provision_node_with_ansible do
      enable_host_auto_discovery
      set_host_key_checking false
      ansible_playbook 'src/ansible/demo.yml', ['--sudo']
    end
  end
...
end
```