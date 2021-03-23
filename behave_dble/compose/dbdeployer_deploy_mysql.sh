#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

set -e;

echo "mysql_version is ${1}"
mysql_version=`echo ${1} | sed 's/\./\_/g'`
echo "mysql_version is: ${mysql_version}"

# initial mysql
#dbdeployer delete --skip-confirm ALL
dbdeployer deploy single ${1} --remote-access % --bind-address 0.0.0.0 -c skip-name-resolve --port-as-server-id --port 3307 -p 111111 -u test --gtid --force

#create soft link
rm -rf /usr/bin/mysql && ln -sf /root/opt/mysql/${1}/bin/mysql /usr/bin/mysql
rm -f /tmp/mysql.sock  && ln -s /tmp/mysql_sandbox3307.sock /tmp/mysql.sock

echo "mysql all install success"