#environment,基础环境依赖自行安装
0, python 2.7, git, wget, gcc等

1, docker环境搭建（详情参考docker_install.txt)

2, 所有容器安装mysql 5.7.13,账户初始设置，复制关系设置等, 并在dble所在容器安装zookeeper 3.4.9, jdk-8u121
  chmod +x en_dble.sh
  ./en_dble.sh

3, 使用pip安装behave 1.2.5，先确保pip可用，安装behave后还要安装测试中需要用到的依赖包：paramiko,PyYAML,hamcrest,lxml,MySQLdb
    yum -y install epel-release
    pip install --upgrade pip

    pip install git+https://github.com/behave/behave@v1.2.5

    #module: paramiko, yaml, hamcrest
    pip install paramiko
    pip install PyYAML
    pip install PyHamcrest

    #module: MySQLdb
    yum install python-devel
    pip install mysql-devel

    #module: lxml
    pip install lxml