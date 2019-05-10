Linux ubuntu:18.04 环境下运行 C++ driver 代码说明：

1.安装依赖包,执行：
apt update && apt install -y wget vim build-essential libboost1.65-dev gdb git cmake libmysqlclient-dev

2.在/opt/目录下导入整个Connector-cpp 项目

3.在opt目录下安装并编译 yaml-cpp，执行：
cd /opt
wget https://github.com/jbeder/yaml-cpp/archive/release-0.5.1.tar.gz && tar zxvf /opt/release-0.5.1.tar.gz
cd yaml-cpp-release-0.5.1 && mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..;make -j 3;make install

4.配置环境变量，执行：
echo "export LD_LIBRARY_PATH=/usr/local/lib">>/root/.bashrc

5..在opt目录下安装并编译mysql-connector-c++-1.1.11，执行：
cd /opt
wget https://dev.mysql.com/get/Downloads/Connector-C++/mysql-connector-c++-1.1.11.tar.gz && tar zxvf mysql-connector-c++-1.1.11.tar.gz
cd mysql-connector-c++-1.1.11
cmake .; make -j 3; make install
注：编译如未通过，请参考 https://bugs.mysql.com/bug.php?id=90727

6.回到自动化项目目录，以拆分表的配置文件重启一遍dble，执行：
behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

7.编译C++源码：
在源码所在目录Connector-cpp/src ，执行：g++ *.cpp -l mysqlcppconn -l yaml-cpp

8.运行;
在目录Connector-cpp，执行：bash run.sh [-c]
注：1).加 -c 表示 生成的结果需要和标准sql文件做比对，
    2).覆盖的sql文件位置：dble/drivers/Connector-cpp/assets/sql