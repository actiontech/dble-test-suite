#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature  features/func_test/connection features/func_test/managercmd