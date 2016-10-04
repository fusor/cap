# CAP Project

## Vagrant

A Vagrant virtual environment is provided based on the Red Hat Container Development Kit

 - Overview:
    - https://developers.redhat.com/products/cdk/overview/
 - CDK Installation Guide:    
  - https://access.redhat.com/documentation/en/red-hat-container-development-kit/2.2/paged/installation-guide/
 - RHEL Blog Post talking about CDK from 2/2016
  - http://rhelblog.redhat.com/2016/02/25/getting-started-with-the-red-hat-container-development-kit-cdk/



### Vagrant Usage

 1. Download and install the vagrant base box, must be installed as 'cdkv2' as per CDK instructions.
  - Download base box from https://access.redhat.com/downloads/content/293/
  - Add box, example for virtualbox:
     - `vagrant box add --name cdkv2 ~/Downloads/rhel-cdk-kubernetes-7.2.x86_64.vagrant-virtualbox.box*`
 1. Checkout dependent projects on peer with 'fusor/cap'
  - `git clone https://github.com/fusor/cap-ui.git`
  - `git clone https://github.com/fusor/cap-server.git`
 1. Install the required vagrant plugins
  - `vagrant plugin install vagrant-service-manager vagrant-registration vagrant-sshfs landrush`
 1. Define environment variables for subscription-manager
  - export SUB_USERNAME=name
  - export SUB_PASSWORD=password
 1. `vagrant up`
 1. visit: http://cap.example.com:3000
   - a tmux session is running on the VM which contains the development servers for go & react
     1. `vagrant ssh`
     1. `tmux attach-session -t dev`


### Dependencies

Git Projects:
 - https://github.com/fusor/cap-ui
 - https://github.com/fusor/cap-server

### Servers

Project uses 2 servers, one that's strictly a dev api server for exposing
nulecule data to the client. The second is the react dev server. It's a simple
node server with some niceties for building and serving the react application
and auto reloading react components, in browser errors etc.

These are two distinct services running on two separate ports.
  - 3000 for the react app (fusor/cap-ui)
  - 3001 for the api server written in Go (fusor/cap-server)


##### Running the server processes

A tmux session is configured by default to automatically run both the react and go servers.

To attach to the tmux session:  
  - `tmux attach-session -t dev`
    - This tmux session is created by the script: `/vagrant/setup/run_dev_servers_in_tmux.sh`

To test the backend Go services is working:

 - `curl http://cap.example.com:3001/nulecules`

To test the frontend React service is up:

 - visit http://cap.example.com:3000


## Extra Reading Information

 - Test Driving OpenShift with the Red Hat Container Development Kit (CDK)
  - http://rhelblog.redhat.com/2016/03/07/test-driving-openshift-with-the-red-hat-container-development-kit-cdk/
