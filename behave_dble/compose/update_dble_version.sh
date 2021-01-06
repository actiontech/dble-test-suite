#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#!/bin/bash
set -e;
#version like 2.19.09.0 or 9.9.9.9
version=${1-"9.9.9.9"}
old_dble_exists=0

if [ -x "/opt/dble/bin/dble" ]; then
    old_dble_exists=1
    conf_path="dble_`date '+%Y-%m-%d_%H:%M:%S'`"

#   stop running dble
    /opt/dble/bin/dble stop

#   mv dble conf for reuse
    mv /opt/dble/conf /tmp/${conf_path}

    rm -rf /opt/dble
fi
rm -rf actiontech-dble.tar.gz
cd /opt && wget ftp://ftp:ftp@10.186.18.20/actiontech-dble/qa/${version}/actiontech-dble.tar.gz
tar -zxf actiontech-dble.tar.gz -C /opt

if [ ${old_dble_exists} -eq 1 ]; then
# reuse old dble conf if exists and start dble
  rm -rf /opt/dble/conf \
  && mv /tmp/${conf_path} /opt/dble/conf \
  && /opt/dble/bin/dble start
else
  echo "dble is first installed!!!"
fi