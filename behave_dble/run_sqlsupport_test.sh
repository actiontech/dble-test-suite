#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
pipenv run behave -Dreset=false -D dble_conf=sql_cover_mixed features/install_uninstall/install_dble.feature features/sql_cover/special/
pipenv run behave -D dble_conf=sql_cover_global features/sql_cover/sql_global.feature
pipenv run behave -D dble_conf=sql_cover_nosharding features/sql_cover/sql_nosharding.feature
pipenv run behave -D dble_conf=sql_cover_sharding features/sql_cover/sql_sharding.feature
pipenv run behave -D dble_conf=sql_cover_mixed features/sql_cover/sql_mixed.feature