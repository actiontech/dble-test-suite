> environment,基础环境依赖自行安装
0, python 2.7, git, wget, gcc等

#1.docker环境搭建（详情参考docker_install.txt)

#2.所有容器安装mysql 5.7.13,账户初始设置，复制关系设置等, 并在dble所在容器安装zookeeper 3.4.9, jdk-8u121
  chmod +x env_dble.sh
  
  ./env_dble.sh

#3.使用pip安装behave 1.2.5，先确保pip可用，安装behave后还要安装测试中需要用到的依赖包：paramiko,PyYAML,hamcrest,lxml,MySQLdb
```
    yum -y install epel-release
    (if pip: command not found, yum install -y python-pip)
    pip install --upgrade pip

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
    conn=MySQLdb.connect('127.0.0.1', 'test','111111','',3306)
    cur=conn.cursor()
    cur.execute('select 1')
    cur.fetchall()
    cur.close()
    conn.close()
```