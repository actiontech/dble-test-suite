#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
if [ ! -f "sys.config" ]; then
	ln ../../sys.config sys.config
fi