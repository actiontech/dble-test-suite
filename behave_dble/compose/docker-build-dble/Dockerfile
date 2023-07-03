FROM centos:centos7

RUN sed -i.backup 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf && \
    rm -rf /etc/yum.repos.d/* && \
    curl -fSL http://mirrors.aliyun.com/repo/Centos-7.repo -o /etc/yum.repos.d/CentOS-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-7.repo && \
    curl -fSL http://mirrors.aliyun.com/repo/epel-7.repo -o /etc/yum.repos.d/epel-7.repo && \
    yum clean all && \
    yum makecache && \
    yum update -y && \
    yum clean all && \
    rm -rf /tmp/*

RUN yum install -y openssh-server openssh-clients net-tools vim lrzsz mlocate tcpdump make iproute iptables wget numactl.x86_64 libaio bash-completion bash-completion-extras openssl gcc python3-devel.x86_64 mysql-devel && \
    yum clean all && \
    echo 'root:sshpass' | chpasswd && \
    sed -i 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd && \
    sed -i 's/GSSAPIAuthentication.*/GSSAPIAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    localedef -i zh_CN -f UTF-8 zh_CN.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LC_ALL=zh_CN.UTF-8

RUN echo "" >> /lib/systemd/system/systemd-user-sessions.service && \
    echo "[Install]" >> /lib/systemd/system/systemd-user-sessions.service && \
    echo "WantedBy=multi-user.target" >> /lib/systemd/system/systemd-user-sessions.service && \
    systemctl enable systemd-user-sessions && \
    systemctl enable sshd

##install python3 and dependency for custom_mysql_ha
#RUN yum install -y gcc python3-devel.x86_64 mysql-devel &&\
RUN pip3 install six -i http://pypi.douban.com/simple --trusted-host pypi.douban.com &&\
    pip3 install coloredlogs -i http://pypi.douban.com/simple --trusted-host pypi.douban.com &&\
    pip3 install rsa -i http://pypi.douban.com/simple --trusted-host pypi.douban.com &&\
    pip3 install mysqlclient -i http://pypi.douban.com/simple --trusted-host pypi.douban.com &&\
    ln -s /usr/local/mysql/lib/libmysqlclient.so.20.3.0 /usr/lib64/libmysqlclient.so.20

# install jdk
COPY jdk-8u261-linux-x64.tar.gz /tmp/jdk-8u261-linux-x64.tar.gz
RUN mkdir /opt/jdk  && \
    tar -zxf /tmp/jdk-8u261-linux-x64.tar.gz -C /opt/jdk --strip-components=1  && \
    echo "export JAVA_HOME=/opt/jdk">>/etc/bashrc && \
    rm -rf /tmp/jdk-8u261-linux-x64.tar.gz

#install btrace
RUN wget -P /tmp https://github.com/btraceio/btrace/releases/download/v1.3.11/btrace-bin-1.3.11.tgz.tar.gz && \
    mkdir /opt/btrace && \
    tar -zxf /tmp/btrace-bin-1.3.11.tgz.tar.gz -C /opt/btrace && \
    sed -i 's/java -cp/java -Dcom.sun.btrace.unsafe=true -cp/' /opt/btrace/bin/btrace && \
    rm -rf /tmp/btrace-bin-1.3.11.tgz.tar.gz

# install dbdeployer
COPY dbdeployer_completion.sh /dbdeployer_completion.sh
RUN VERSION=1.58.2 && \
    OS=linux && \
    origin=https://github.com/datacharmer/dbdeployer/releases/download/v$VERSION && \
    wget -q $origin/dbdeployer-$VERSION.$OS.tar.gz && \
    tar -xzf dbdeployer-$VERSION.$OS.tar.gz && \
    chmod +x dbdeployer-$VERSION.$OS && \
    mv dbdeployer-$VERSION.$OS /usr/local/bin/dbdeployer && \
    dbdeployer init --skip-tarball-download --skip-shell-completion && \
    dbdeployer defaults enable-bash-completion /dbdeployer_completion.sh && \
    dbdeployer defaults update reserved-ports '1186' && \
    dbdeployer downloads get-unpack mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && \
    dbdeployer downloads get-unpack mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz && \
    rm -f dbdeployer-$VERSION.$OS.tar.gz && \
    rm -f mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz && \
    rm -f mysql-8.0.18-linux-glibc2.12-x86_64.tar.xz && \
    rm -f /dbdeployer_completion.sh

#install zookeeper
RUN wget -P /tmp https://archive.apache.org/dist/zookeeper/zookeeper-3.5.2-alpha/zookeeper-3.5.2-alpha.tar.gz && \
    mkdir /opt/zookeeper && \
    tar -zxf /tmp/zookeeper-3.5.2-alpha.tar.gz -C /opt/zookeeper --strip-components=1 && \
    echo " ">> /opt/zookeeper/conf/zoo.cfg && \
    sed -i "$ a tickTime=2000\ninitLimit=10\nsyncLimit=5 \nclientPort=2181" /opt/zookeeper/conf/zoo.cfg && \
    sed -i "$ a dataDir=/opt/zookeeper/data\ndataLoginDir=/opt/zookeeper/logs" /opt/zookeeper/conf/zoo.cfg && \
    sed -i "$ a server.1=dble-1:2888:3888\nserver.2=dble-2:2888:3888\nserver.3=dble-3:2888:3888" /opt/zookeeper/conf/zoo.cfg && \
    mkdir /opt/zookeeper/data/ && \
    rm -rf /tmp/zookeeper-3.5.2-alpha.tar.gz

RUN echo "export PATH=/opt/zookeeper/bin:/opt/btrace/bin/:/usr/local/mysql/bin:/opt/jdk/bin:$PATH">>/etc/bashrc

COPY * /docker-build/

VOLUME ["/sys/fs/cgroup"]

CMD ["/usr/sbin/init"]
