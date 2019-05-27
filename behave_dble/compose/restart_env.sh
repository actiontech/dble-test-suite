#!/usr/bin/env bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#restarting server for power off or any other reason, you can run this script to restart service for autotest
base_dir=$( dirname ${BASH_SOURCE[0]} )

sudo systemctl start docker.service
cd ${base_dir} && docker-compose start
bash resetReplication.sh