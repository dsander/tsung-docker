#!/bin/bash

# Utility to run tsung and automatically generate reports

# make sure SSHD is started in order to connect to other tsung agents
service ssh start


slave=$(echo $SLAVE)
if [[ -n "${slave}" ]]; then
    echo "Running in SLAVE mode ..."
    tail -f /dev/null
    exit
fi

cat $TSUNG_CONFIG | grep "client host"| sed -e 's/.*<client\ host="\([^"]\)/\1/' | sed -e 's/"\s*cpu.*//' | \
  while read host ; do
    echo "Waiting for $host to come available"
    while ! ping -c1 $host &>/dev/null; do sleep 0.5; done
  done

current_date=$(date +%Y%m%d-%H%M)
echo "Tsung log directory should be ${current_date}"
cmd="tsung -l /usr/local/tsung/ -f ${TSUNG_CONFIG} "$@
echo "Executin ${cmd} ..."
${cmd}
cd /usr/local/tsung/${current_date}/ && /usr/lib/tsung/bin/tsung_stats.pl
