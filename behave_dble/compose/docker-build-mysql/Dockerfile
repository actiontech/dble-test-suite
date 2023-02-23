FROM centos:centos7

RUN sed -i.backup 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf && \
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    yum clean all

RUN yum install -y openssh-server openssh-clients wget numactl libaio bash-completion bash-completion-extras iptables && \
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
    echo "WantedBy=multi-user.target" >> /lib/systemd/system/systemd-user-sessions.service

RUN systemctl enable systemd-user-sessions && \
    systemctl enable sshd

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

COPY * /docker-build/

VOLUME ["/sys/fs/cgroup"]

CMD ["/usr/sbin/init"]