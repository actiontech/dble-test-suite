#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

echo '=======            package               ======='
/usr/local/apache-maven/bin/mvn -DskipTest clean package assembly:assembly
echo '=======     start jdbc_api_test          ======='
cd target && java -jar jdbc_api_test-1.0-jar-with-dependencies.jar
echo '=======    START SUCCESS jdbc_api_test   ======='
