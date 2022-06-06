#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

echo '=======          copy sys.config         ======='
cp ../../java-interface/JDBCInterfaceTest/sys.config ../
echo '=======            package               ======='
cd ../../jdbc-api-test && mvn -DskipTest clean package assembly:assembly
echo '=======    copy jdbc_api_test-1.0-jar-with-dependencies.jar    ======='
cp target/jdbc_api_test-1.0-jar-with-dependencies.jar ../java
echo '=======     start jdbc_api_test          ======='
cd ../java && java -jar jdbc_api_test-1.0-jar-with-dependencies.jar
echo '=======    START SUCCESS jdbc_api_test   ======='
