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

# dbdeployer
```bash
$ dbdeployer --version
dbdeployer version 1.58.2
```

# build command
```bash
$ docker build -t docker-registry:5000/actiontech/centos7-dbdeployer:1.58.2 .
$ docker tag docker-registry:5000/actiontech/centos7-dbdeployer:1.58.2 docker-registry:5000/actiontech/centos7-dbdeployer:latest
$ docker push docker-registry:5000/actiontech/centos7-dbdeployer:latest
$ docker push docker-registry:5000/actiontech/centos7-dbdeployer:1.58.2
```

# docker test
```bash
$ docker run -itd --privileged --name=test docker-registry:5000/actiontech/centos7-dbdeployer:1.58.2
```