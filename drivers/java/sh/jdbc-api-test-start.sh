#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
echo '=======           modify  capClientFoundRows=true and then restart dble                 ======='
ssh root@dble-1 "sed -i '\$a -DcapClientFoundRows=true' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart"
echo '=======          copy sys.config         ======='
cp ../../java-interface/JDBCInterfaceTest/sys.config ../
echo '=======            package               ======='
cd ../../jdbc-api-test && /usr/local/apache-maven-3.6.3/bin/mvn -DskipTest clean package assembly:assembly
echo '=======    copy jdbc_api_test-1.0-jar-with-dependencies.jar    ======='
cp target/jdbc_api_test-1.0-jar-with-dependencies.jar ../java
echo '=======     start jdbc_api_test          ======='
cd ../java && java -jar jdbc_api_test-1.0-jar-with-dependencies.jar
echo '=======    START SUCCESS jdbc_api_test   ======='
echo '=======    restore capClientFoundRows to default   ======='
ssh root@dble-1 "sed -i -e '/capClientFoundRows/d' /opt/dble/conf/bootstrap.cnf && /opt/dble/bin/dble restart"
