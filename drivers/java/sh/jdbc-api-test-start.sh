echo '=======          copy sys.config         ======='
cp ../../java-interface/JDBCInterfaceTest/sys.config ../
echo '=======            package               ======='
cd ../../jdbc-api-test && mvn -DskipTest clean install
echo '=======    copy jdbc_api_test-1.0.jar    ======='
cp target/jdbc_api_test-1.0.jar ../java
echo '=======     start jdbc_api_test          ======='
cd ../java && java -jar jdbc_api_test.jar
echo '=======    START SUCCESS jdbc_api_test   ======='