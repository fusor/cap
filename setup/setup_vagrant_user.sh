#!/bin/sh

pushd .
cd ~
mkdir -p {src,bin,pkg}

echo "export GOPATH=$HOME" >> ~/.bashrc
echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc

sudo chown -R vagrant:vagrant /home/vagrant/src

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
if [ "$?" -ne "0" ]; then
    exit
fi

source ~/.bash_profile
nvm install 6.5
if [ "$?" -ne "0" ]; then
    exit
fi

nvm use 6.5
if [ "$?" -ne "0" ]; then
    exit
fi

cd /home/vagrant/cap-ui
# Be aware of an issue of npm install on virtualbox and their sharedfold implementation
# I've seen occasional problems replace "npm install" with "npm install --no-bin-links" has helped
# https://github.com/npm/npm/issues/992#issuecomment-223479918
# https://github.com/npm/npm/issues/9633
# Have run into issue of npm install on shared folder with Vagrant & VirtualBox
#
npm install
if [ "$?" -ne "0" ]; then
    exit
fi
popd
