From centos:centos7

#libaio numaactl.x86_64 needed by mysql
RUN yum install -y wget net-tools libaio numactl.x86_64 openssh-clients openssh-server libmysqlclient gcc python3-devel.x86_64 vim less iproute && \
    yum clean all && \
    yum install -y openssl > /tmp/install_openssl.log && \
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

COPY my.cnf /etc/my.cnf
COPY mysql_init.sh /usr/local/bin/mysql_init.sh
RUN chmod +x /usr/local/bin/mysql_init.sh

#install mysql
COPY mysql-8.0.21-linux-glibc2.12-x86_64.tar.xz /tmp/mysql-8.0.21-linux-glibc2.12-x86_64.tar.xz
RUN mkdir /usr/local/mysql && \
    echo "$(pwd)"  && \
    echo "ls -l" && \
    tar xvf /tmp/mysql-8.0.21-linux-glibc2.12-x86_64.tar.xz -C /usr/local/mysql --strip-components=1 && \
    groupadd mysql && \
    useradd -r -g mysql -s /bin/false mysql && \
    cd /usr/local/mysql && mkdir data && chown -R mysql:mysql . && \
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '111111';" > /usr/local/mysql/mysql-init && \
    echo "export PATH=/usr/local/mysql/bin:$PATH">>/etc/bashrc && \
    rm -f /tmp/mysql-8.0.21-linux-glibc2.12-x86_64.tar.xz

RUN ssh-keygen -A && \
    mkdir ~/.ssh && \
    echo 'sshpass'| passwd --stdin root

#sshd service
RUN rm -rf /etc/ssh/ssh_host_* && \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N '' && \
    ssh-keygen -t rsa -N ""  -f "/root/.ssh/id_rsa"

COPY * /docker-build/

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]
