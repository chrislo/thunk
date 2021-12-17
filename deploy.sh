NORNS_IP=192.168.0.14

rsync -azP . --exclude .git --exclude test.sc --delete norns:/home/we/dust/code/thunk
echo 'norns.script.load("code/thunk/thunk.lua")' | websocat ws://$NORNS_IP:5555 -n1 --protocol bus.sp.nanomsg.org
