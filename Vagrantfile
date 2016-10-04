# -*- mode: ruby -*-
# vi: set ft=ruby :

# The private network IP of the VM. You will use this IP to connect to OpenShift.
# This variable is ignored for Hyper-V provider.
PUBLIC_ADDRESS="10.1.2.2"

# Number of virtualized CPUs
VM_CPU = ENV['VM_CPU'] || 2

# Amount of available RAM
VM_MEMORY = ENV['VM_MEMORY'] || 8192

# Validate required plugins
REQUIRED_PLUGINS = %w(vagrant-service-manager vagrant-registration vagrant-sshfs landrush)
errors = []

def message(name)
  "#{name} plugin is not installed, run `vagrant plugin install #{name}` to install it."
end
# Validate and collect error message if plugin is not installed
REQUIRED_PLUGINS.each { |plugin| errors << message(plugin) unless Vagrant.has_plugin?(plugin) }
unless errors.empty?
  msg = errors.size > 1 ? "Errors: \n* #{errors.join("\n* ")}" : "Error: #{errors.first}"
  fail Vagrant::Errors::VagrantError.new, msg
end

missing_vars = []
REQUIRED_ENV_VARS = %w(SUB_USERNAME SUB_PASSWORD)
REQUIRED_ENV_VARS.each { |var| missing_vars << var unless ENV.has_key?(var) }
unless missing_vars.empty?
  msg = "Please set the following environment variables then re-run\n"
  msg += missing_vars.join("\n")
  fail Vagrant::Errors::VagrantError.new, msg
end

PROJECTS_GIT_HOME= File.expand_path "../"
##
# These are _golang_ projects that need to be shared into the VM at the $GOPATH/src
##
GO_REQUIRED_PATHS = {
    "github.com/fusor/cap-server" => "#{PROJECTS_GIT_HOME}/cap-server"
}
GO_REQUIRED_PATHS.each do |name, p|
  if !Dir.exists?(p)
    puts "Unable to find a required git clone for #{name} at #{p}"
    exit
  end
end

##
# Non-go related projects we need shared into the VM go here
##
REQUIRED_PATHS = {
    "github.com/fusor/cap-ui" => "#{PROJECTS_GIT_HOME}/cap-ui"
}
REQUIRED_PATHS.each do |name, p|
  if !Dir.exists?(p)
    puts "Unable to find a required git clone for #{name} at #{p}"
    exit
  end
end

Vagrant.configure(2) do |config|
  config.vm.hostname = "cap.example.com"
  # Blog post on landrush:  http://developers.redhat.com/blog/2016/05/27/use-vagrant-landrush-to-add-dns-features-to-your-openshift-cdk-machine/
  config.landrush.enabled = true
  config.landrush.host_ip_address = "#{PUBLIC_ADDRESS}"
  config.landrush.tld = 'cap.example.com'
  config.landrush.host '.cap.example.com', "#{PUBLIC_ADDRESS}"
  # guest_redirect_dns = false, fixed issue with docker unable to fetch images
  config.landrush.guest_redirect_dns = false

  config.vm.provider "virtualbox" do |v, override|
    v.memory = VM_MEMORY
    v.cpus   = VM_CPU
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    #override.vm.box = "rhel-cdk-kubernetes-7.2-29.x86_64.vagrant-virtualbox.box"
    override.vm.box = "cdkv2"
    override.vm.box_url = "http://file.rdu.redhat.com/~jmatthew/vagrant/CDK/7.2-29.x86_64/virtualbox/rhel-cdk-kubernetes-7.2-29.x86_64.vagrant-virtualbox.box"

  end

  config.vm.provider "libvirt" do |v, override|
    v.memory = VM_MEMORY
    v.cpus   = VM_CPU
    v.driver = "kvm"
    v.suspend_mode = "managedsave"
    override.vm.box = "cdkv2"
    #override.vm.box = "rhel-cdk-kubernetes-7.2-29.x86_64.vagrant-libvirt.box"
    override.vm.box_url = "http://file.rdu.redhat.com/~jmatthew/vagrant/CDK/7.2-29.x86_64/libvirt/rhel-cdk-kubernetes-7.2-29.x86_64.vagrant-libvirt.box"
  end

  config.vm.network "private_network", ip: "#{PUBLIC_ADDRESS}"

  # vagrant-registration
  if ENV.has_key?('SUB_USERNAME') && ENV.has_key?('SUB_PASSWORD')
    config.registration.username = ENV['SUB_USERNAME']
    config.registration.password = ENV['SUB_PASSWORD']
  end

  # Proxy Information from environment
  config.registration.proxy = PROXY = (ENV['PROXY'] || '')
  config.registration.proxyUser = PROXY_USER = (ENV['PROXY_USER'] || '')
  config.registration.proxyPassword = PROXY_PASSWORD = (ENV['PROXY_PASSWORD'] || '')

  config.vm.synced_folder '.', '/vagrant', type: 'sshfs', sshfs_opts_append: '-o umask=000 -o uid=1000 -o gid=1000'

  REQUIRED_PATHS.each do |name, p|
    basename = File.basename(name)
    config.vm.synced_folder p, "/home/vagrant/#{basename}", type: 'sshfs', sshfs_opts_append: '-o umask=000 -o uid=1000 -o gid=1000'
  end

  # These paths will be under the $GOPATH on the VM
  GO_REQUIRED_PATHS.each do |name, p|
    config.vm.synced_folder p, "/home/vagrant/src/#{name}", type: 'sshfs', sshfs_opts_append: '-o umask=000 -o uid=1000 -o gid=1000'
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo setsebool -P virt_sandbox_use_fusefs 1
  SHELL

  # prevent the automatic start of openshift via service-manager by just enabling Docker
  config.servicemanager.services = "docker"

  config.vm.provision "shell", inline: <<-SHELL
    sudo sed -i 's/^OPENSHIFT_SUBDOMAIN=.*/OPENSHIFT_SUBDOMAIN="$(hostname)"/' /etc/sysconfig/openshift_option
    sudo systemctl enable openshift
    sudo systemctl start openshift
  SHELL

  # explicitly enable and start OpenShift
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    PROXY=#{PROXY} PROXY_USER=#{PROXY_USER} PROXY_PASSWORD=#{PROXY_PASSWORD} /usr/bin/sccli openshift
  SHELL

  config.vm.provision :shell, :path => "setup/provision.sh"
  config.vm.provision :shell, :path => "setup/setup_vagrant_user.sh", :privileged => false
  config.vm.provision :shell, :path => "setup/run_dev_servers_in_tmux.sh", :privileged => false

  config.vm.provision "shell", run: "always", inline: <<-SHELL
    #Get the routable IP address of OpenShift
    OSIP=`/opt/adb/openshift/get_ip_address`
    echo
    echo "Successfully started and provisioned VM with #{VM_CPU} cores and #{VM_MEMORY} MB of memory."
    echo "To modify the number of cores and/or available memory set the environment variables"
    echo "VM_CPU respectively VM_MEMORY."
    echo
    echo "You can now access the OpenShift console on: https://${OSIP}:8443/console"
    echo
    echo "To use OpenShift CLI, run:"
    echo "$ vagrant ssh"
    echo "$ oc login"
    echo
    echo "Configured users are (<username>/<password>):"
    echo "openshift-dev/devel"
    echo "admin/admin"
    echo
    echo "If you have the oc client library on your host, you can also login from your host."
    echo
  SHELL

  config.vm.provision "shell", run: "always", inline: <<-SHELL
    echo
    echo "tmux is running react & go applications"
    echo "tmux attach-session -t dev"
    echo ""
    echo "Visit:  http://cap.example.com:3000"
    echo ""
    echo
  SHELL
end
