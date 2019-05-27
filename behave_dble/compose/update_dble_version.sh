#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#2.17.09.0
#9.9.9.9
#2.18.02.1
version=${1-"9.9.9.9"}
conf_path="dble_`date '+%Y-%m-%d_%H:%M:%S'`"

/opt/dble/bin/dble stop
rm -rf actiontech-dble.tar.gz
cd /opt && wget ftp://ftp:ftp@10.186.18.20/actiontech-dble/qa/${version}/actiontech-dble.tar.gz \
&& mv /opt/dble/conf /tmp/${conf_path}
rm -rf /opt/dble
cd /opt && tar -zxf actiontech-dble.tar.gz
rm -rf /opt/dble/conf
mv /tmp/${conf_path} /opt/dble/conf
/opt/dble/bin/dble start