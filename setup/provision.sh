#!/usr/bin/env bash

subscription-manager repos --disable=*
if [ "$?" -ne "0" ]; then
    exit
fi

subscription-manager repos --enable rhel-7-server-rpms
if [ "$?" -ne "0" ]; then
    exit
fi

# Adding rhel7 optional to work around problem from:
subscription-manager repos --enable rhel-7-server-optional-rpms
if [ "$?" -ne "0" ]; then
    exit
fi

# Installing EPEL to give us python-pip
rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
if [ "$?" -ne "0" ]; then
    exit
fi

# misc rpms to make life easier for us
yum install -y tmux vim-enhanced bind-utils net-tools tig
if [ "$?" -ne "0" ]; then
    exit
fi

yum install -y python-pip python-devel gcc
if [ "$?" -ne "0" ]; then
    exit
fi

yum install -y golang golang-vim
if [ "$?" -ne "0" ]; then
    exit
fi

# TODO: remove this once we switch over to all atomic
yum install -y atomicapp
if [ "$?" -ne "0" ]; then
    exit
fi
