#!/bin/sh

export CAP_SERVER="$GOPATH/src/github.com/fusor/cap-server"

cd $CAP_SERVER
go get
go build

tmux new-session -s "dev" -n "cap-server" -d "cd ${CAP_SERVER} && ./cap-server; bash -i"

# Skip a UI build if the developer has vagrant set in UI_DEV mode
# While in UI_DEV mode, the developer is expected to be running the react build
# server on a host machine and producing js builds to cap-ui/build
if ! [ "$1" == "--uidev" ]; then
  pushd /home/vagrant/cap-ui && npm run build && popd
fi
