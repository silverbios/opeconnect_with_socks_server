#! /bin/sh

# https://www.infradead.org/openconnect/index.html
iptables-restore < /openconnect/iptables
# add route if you have seprate network from this container
ip route add 192.168.1.0/24 via 192.168.1.1 dev eth0
env | sort | grep OPENCONNECT_
cmd="/usr/sbin/sockd"
nohup $cmd &

OPTIONS="$( \
          env | \
          grep ^OPENCONNECT_ | \
          grep -v ^OPENCONNECT_PASSWORD_FILE= | \
          grep -v ^OPENCONNECT_SERVER= | \
          grep -v ^OPENCONNECT_SUDO= | \
          grep -v =false$ | \
          awk -F'=' '{gsub("^OPENCONNECT_", "--", $1); gsub("_", "-", $1); print tolower($1) "=" $2}' | \
          awk '{gsub("=true", "", $0); print $0}' | \
          xargs \
        )"

if [ $OCPROXY_ENABLED ]; then
  export OCPROXY_PORT=${OCPROXY_PORT:-1080}

  OPTIONS="$OPTIONS --script-tun --script=/openconnect/ocproxy.sh"

fi

echo
echo OPTIONS=$OPTIONS
echo
if [ -f $OPENCONNECT_CONFIG ]; then
  echo Config file $OPENCONNECT_CONFIG ...
  cat $OPENCONNECT_CONFIG
  echo
fi

echo Starting openconnect
echo

if [ -f $OPENCONNECT_PASSWORD_FILE ]; then
  OPTIONS="$OPTIONS --passwd-on-stdin"
  exec openconnect ${OPTIONS} ${OPENCONNECT_SERVER} < $OPENCONNECT_PASSWORD_FILE
else
  exec openconnect ${OPTIONS} ${OPENCONNECT_SERVER}
fi
