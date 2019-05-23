### 一、基础环境

linux Centos7 ，基础环境依赖自行安装: python 2.7, git, wget, gcc-c++等

### 二、测试环境搭建步骤：

1.安装docker 和 docker-compose, 启动 docker 服务

2.clone自动化测试项目，创建目录/opt/behave/,执行

    cd /opt/behave/
    git clone https://github.com/actiontech/dble-test-suite.git 
    
3.打包镜像

```
a.下载生成镜像所需的安装包，进入到dble-test-suite目录
   
  1) cd behave_dble/compose/docker-build-behave/ 
  
     下载jdk安装包：jdk-8u121-linux-x64.tar.gz 
     
  2) cd behave_dble/compose/docker-build-general/
   
     下载jdk安装包：jdk-8u121-linux-x64.tar.gz 
     下载mysql安装包：mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz  
     下载btrace安装包：btrace-bin-1.3.11.tgz.tar.gz 
     下载zookeeper安装包：zookeeper-3.5.2-alpha.tar.gz 

b.打包镜像，进入到dble-test-suite目录， 分别执行：
  sudo docker build -t dble_test_general:latest  behave_dble/compose/docker-build-general/
  sudo docker build -t dble_test_client:latest   behave_dble/compose/docker-build-behave/
  sudo docker build -t dble_test_driver:latest   behave_dble/compose/docker-build-driver/
```
4.搭建测试环境
```
cd dble-test-suite/behave_dble/compose/ 目录，执行脚本 start_env.sh 
```
5.执行测试
```
cd dble-test-suite/behave_dble/compose/ 目录,执行脚本 start_dble_test.sh,完成 功能feature和sql覆盖的测试。
```
### 三、driver测试步骤请参考各driver下的readme.md
