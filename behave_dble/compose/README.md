该说明针对公司OpenNebula平台下的"centos7 - KVM" 模板创建的虚拟机成功运行，创建虚拟机时间为2018.11.15，如果是其它平台或者模板发生变更，可能会有部分软件缺失，请自行安装
> environment,基础环境依赖自行安装
0, python 2.7, git, wget, gcc-c++等

#1.docker环境搭建（详情参考docker_install.txt)

#2.所有容器安装mysql 5.7.13,账户初始设置，复制关系设置等, 并在dble所在容器安装zookeeper 3.4.9, jdk-8u121
  
  准备安装文件:   
  + 2.1 在compose目录下新建sources目录：mkdir sources  
  + 2.2 将mysql， zookeeper，jdk的相应linux安装文件放在sources目录下   
  + 2.3 sources目录下同一应用安装文件不能有多份：eg,不能有2份mysql开头的安装文件， 安装文件命名格式满足：  
  mysql-xxx.tar.gz  
  zookeeper-xxx.tar.gz  
  jdk-xxx.tar.gz  
  ssh-keygen -t rsa  
  chmod +x env_dble.sh  
  ./env_dble.sh  
  if used for ci, change own:   
  chown -R go:go /opt/auto_build  

#3.使用pip安装behave 1.2.5，先确保pip可用，安装behave后还要安装测试中需要用到的依赖包：paramiko,PyYAML,hamcrest,lxml,MySQLdb
```
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
```
#4 安装mysql客户端供c++编译用
本步骤依赖于第二步sources文件存在

tar -zxf /opt/auto_build/mysql*.tar.gz -C /opt
mv /opt/mysql* /opt/mysql

echo "/opt/mysql/lib" >>/etc/ld.so.conf.d/mariadb-x86_64.conf
ldconfig

