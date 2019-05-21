#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
if [ ! -f "sys.config" ]; then
	ln ../../sys.config sys.config
fi