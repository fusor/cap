#!/bin/sh

export CAP_SERVER="$GOPATH/src/github.com/fusor/cap-server"

cd $CAP_SERVER
go get
go build

tmux new-session -s "dev" -n react -d "cd /home/vagrant/cap-ui && npm start; bash -i"
tmux new-window -t "dev:1" -n "cap-server" "cd ${CAP_SERVER} && ./cap-server; bash -i"
