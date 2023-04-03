# linux version
```bash
$ cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
```

# jdk
```bash
$ java -version
java version "1.8.0_121"
Java(TM) SE Runtime Environment (build 1.8.0_121-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
```

# btrace
```bash
$ btrace --version
BTrace v.1.3.11 (20180406)
```

# dbdeployer
```bash
$ dbdeployer -v
dbdeployer version 1.58.2
```

# zookeeper
```bash
3.5.2-alpha-1750793
```

# build command
```bash
$ docker build -t docker-registry:5000/actiontech/dble-runtime-centos7:v1 .
$ docker tag docker-registry:5000/actiontech/dble-runtime-centos7:v1 docker-registry:5000/actiontech/dble-runtime-centos7:latest
$ docker push docker-registry:5000/actiontech/dble-runtime-centos7:latest
$ docker push docker-registry:5000/actiontech/dble-runtime-centos7:v1
```

# docker test
```bash
$ docker run -itd --privileged --name=test docker-registry:5000/actiontech/dble-runtime-centos7:v1
```