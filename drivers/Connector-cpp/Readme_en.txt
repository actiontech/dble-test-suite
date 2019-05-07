1. Create docker and get essentials
docker pull ubuntu:18.04
docker run -it --privileged ubuntu:18.04
apt update && apt install -y wget vim build-essential libboost1.65-dev gdb git
mkdir /opt/cpp (and move all srs code to this directory)

2. Get yaml-cpp and build
cd /opt
wget https://github.com/jbeder/yaml-cpp/archive/release-0.5.1.tar.gz
cd yaml-cpp-release-0.5.1
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..;make -j 3;make install

3. execute echo "export LD_LIBRARY_PATH=/usr/local/lib">>/root/.bashrc

4. Get mysql-connector-c++-1.1.11(source version) and build
cd /opt
wget https://dev.mysql.com/get/Downloads/Connector-C++/mysql-connector-c++-1.1.11.tar.gz
tar zxf mysql-connector-c++-1.1.11.tar.gz
cd /opt/mysql-connector-c++-1.1.11
apt install -y cmake libmysqlclient-dev
cmake .; make -j 3; make install
note:maybe occur this issue: https://bugs.mysql.com/bug.php?id=90727  (remove line 703-704 from FindMySQL.cmake file)

5.execute：behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

6.Compile and run
cd /opt/cpp
g++ *.cpp -l mysqlcppconn -l yaml-cpp
./a.out "" "conf/auto_dble_test.yaml" "driver_test_client.sql" "driver_test_manager.sql"