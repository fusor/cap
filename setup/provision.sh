#!/usr/bin/env bash

#
# repositories we need enabled
#
repos=(rhel-7-server-rpms
rhel-7-server-optional-rpms # Adding rhel7 option to work around problems
)

#
# packages we need to install
#
pkgs=(tmux # misc rpms to make life easier for us
vim-enhanced
bind-utils
net-tools
tig

# python bits
python-pip
python-devel
gcc

# golang bits
golang
golang-vim

atomicapp # TODO: remove this once we switch over to all atomic
)

###################################################################
# MAIN
###################################################################

#
# Disable unneeded repos
#
subscription-manager repos --disable=* > /dev/null
if [ "$?" -ne "0" ]; then
    exit
fi

#
# Enable the required repos
#
for repo in "${repos[@]}"
do
    ENABLED_REPOS=$ENABLED_REPOS" --enable $repo"
done
subscription-manager repos $ENABLED_REPOS
if [ "$?" -ne "0" ]; then
    exit
fi

#
# Installing EPEL to give us python-pip
#
rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
if [ "$?" -ne "0" ]; then
    exit
fi

#
# Install the defined packages
#
for pkg in "${pkgs[@]}"
do
    RPMS=$RPMS" $pkg"
done
yum install -y $RPMS
if [ "$?" -ne "0" ]; then
    exit
fi
