#!/bin/bash
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

DIR="$( cd "$( dirname "$0" )" && pwd )"
echo '=======            package               ======='
cd ${DIR} && /usr/local/apache-maven/bin/mvn -DskipTest clean package assembly:assembly
echo '=======     start jdbc_api_test          ======='
cd ${DIR}/target && java -jar jdbc_api_test-1.0-jar-with-dependencies.jar
