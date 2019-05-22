该说明针对公司OpenNebula平台下的"centos7 - KVM" 模板创建的虚拟机成功运行，创建虚拟机时间为2018.11.15，如果是其它平台或者模板发生变更，可能会有部分软件缺失，请自行安装

### 一、基础环境

基础环境依赖自行安装: python 2.7, git, wget, gcc-c++等

### 二、测试环境搭建步骤：

1.安装docker 和 docker-compose,启动docker服务

2.打包镜像

```
a.创建目录 /opt/behave/ ，并导入整个自动化测试项目

b.下载生成镜像所需的安装包
   
  1) cd behave_dble/compose/docker-build-behave/ 
  
     下载jdk安装包：jdk-8u121-linux-x64.tar.gz 
     
  2) cd behave_dble/compose/docker-build-general/
   
     下载jdk安装包：jdk-8u121-linux-x64.tar.gz 
     下载mysql安装包：mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz  
     下载btrace安装包：btrace-bin-1.3.11.tgz.tar.gz 
     下载zookeeper安装包：zookeeper-3.5.2-alpha.tar.gz 

c.打包镜像，进入到dble-test-suite目录， 分别执行：
  sudo docker build -t dble_test_general:latest  behave-dble/compose/docker-build-general/
  sudo docker build -t dble_test_client:latest   behave_dble/compose/docker-build-behave/
```
3.搭建测试环境
```
cd behave_dble/compose/ 目录，执行脚本 start_env.sh 
```
4.执行测试
```
cd behave_dble/compose/ 目录,执行脚本 start_dble_test.sh,完成 功能feature和sql覆盖的测试。
```
### 三、driver测试步骤请参考各driver下的readme.md

### 四、手动搭建环境依赖包安装参考

使用pip安装behave 1.2.5，先确保pip可用，安装behave后还要安装测试中需要用到的依赖包：paramiko,PyYAML,hamcrest,lxml,MySQLdb

    
    yum -y install epel-release
    (if pip: command not found, yum install -y python-pip)
    pip install --upgrade pip
    pip install six==1.11

    pip install git+https://github.com/behave/behave@v1.2.5

    #module: paramiko, yaml, hamcrest
    pip install paramiko
    pip install PyYAML
    pip install PyHamcrest

    #module: MySQLdb
    centos6:
    yum install python-devel
    pip install mysql-devel
    centos7:
    yum install python-devel mysql-devel
    pip install MySQL-python

    #module: lxml
    pip install lxml

    验证MySQLdb安装成功，进入python交互模式成功执行:
    import MySQLdb
    conn=MySQLdb.connect('172.100.9.4', 'test','111111','',3306)
    cur=conn.cursor()
    cur.execute('select 1')
    cur.fetchall()
    cur.close()
    conn.close()


