该说明针对公司OpenNebula平台下的"centos7 - KVM" 模板创建的虚拟机成功运行，创建虚拟机时间为2018.11.15，如果是其它平台或者模板发生变更，可能会有部分软件缺失，请自行安装

### 一、基础环境

基础环境依赖自行安装: python 2.7, git, wget, gcc-c++等

### 二、测试环境搭建步骤：

1.docker环境搭建（详情参考[compose/half-auto-env/docker_install.txt])

2.打包镜像

```
a.创建目录 /opt/behave/ ，并导入整个自动化测试项目（该目录会映射到behave 容器中的 /init_assets 目录，详情参考 docker-compose.yml)

b.请参考Dockerfile，自行下载生成镜像所需的安装包，并放置在Dockerfile同级目录中,该项目有两份dockerfile，分别在目录 behave_dble/compose/docker-build-behave，behave_dble/compose/docker-build-general

c.打包镜像，分别执行：
  sudo docker build -t dble_test_general:latest ${path}/docker-build-general
  sudo docker build -t dble_test_client:latest ${path}/docker-build-behave
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

