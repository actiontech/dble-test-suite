#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

set -e;

echo "mysql version is ${1}"
mysql_version=`echo ${1} | sed 's/\./\_/g'`
echo "mysql_version is: ${mysql_version}"

# initial mysql
#dbdeployer delete --skip-confirm ALL
dbdeployer deploy single ${1} --remote-access % --bind-address 0.0.0.0 -c skip-name-resolve --server-id ${2} --port 3307 -p 111111 \
--my-cnf-options="default_authentication_plugin=mysql_native_password" --my-cnf-options="secure_file_priv=" --my-cnf-options="sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES" \
--my-cnf-options="session_track_schema=1" --my-cnf-options="session_track_state_change=1" --my-cnf-options="session_track_system_variables="*"" \
--pre-grants-sql="create user test@'%' identified with mysql_native_password by '111111';grant all on *.* to test@'%' with grant option;flush privileges;" --gtid --force

#create soft link
rm -rf /usr/bin/mysql && ln -sf /root/opt/mysql/${1}/bin/mysql /usr/bin/mysql
rm -f /tmp/mysql.sock  && ln -s /tmp/mysql_sandbox3307.sock /tmp/mysql.sock

#create different uuid for every mysql
rm -f /root/sandboxes/msb_${mysql_version}/data/auto.cnf
/root/sandboxes/msb_${mysql_version}/restart

echo "mysql all install success"