FROM ubuntu:18.04
MAINTAINER Jolie <wujinling@actionsky.com>

#set CST timezone
RUN echo "Asia/shanghai" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apt-get update && \
#    apt-get  upgrade && \
    apt-get install --fix-missing -y yum-utils vim wget gcc g++ git net-tools libaio1 hwloc openssh-server sshpass ntp ntpdate less iproute2 && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#c/cpp dependency
COPY mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz /tmp/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz
COPY yaml-cpp-release-0.5.1.tar.gz /opt/yaml-cpp-release-0.5.1.tar.gz
COPY mysql-connector-c++-1.1.11.tar.gz /opt/mysql-connector-c++-1.1.11.tar.gz
RUN apt-get update && \
    apt-get install -y curl build-essential libboost1.65-dev gdb cmake libmysqlclient-dev libyaml-cpp-dev iptables && \
#    wget -P /opt https://dev.mysql.com/get/Downloads/Connector-C++/mysql-connector-c++-1.1.11.tar.gz && \
    tar zxvf /opt/mysql-connector-c++-1.1.11.tar.gz -C /opt/ && \
    sed -i -e '/list(APPEND SYS_LIBRARIES "mysql_sys")/d' /opt/mysql-connector-c++-1.1.11/FindMySQL.cmake && \
    sed -i -e '/list(APPEND SYS_LIBRARIES "mysql_strings")/d' /opt/mysql-connector-c++-1.1.11/FindMySQL.cmake && \
    cd /opt/mysql-connector-c++-1.1.11/ &&\
    cmake .; make -j 3; make install &&\
    echo "export LD_LIBRARY_PATH=/usr/local/lib">>/root/.bashrc &&\
#    wget -P /opt https://github.com/jbeder/yaml-cpp/archive/release-0.5.1.tar.gz &&\
    tar zxvf /opt/yaml-cpp-release-0.5.1.tar.gz -C /opt/ &&\
    mkdir /opt/yaml-cpp-release-0.5.1/build &&\
    cd /opt/yaml-cpp-release-0.5.1/build &&\
    cmake -DBUILD_SHARED_LIBS=ON ..;make -j 3;make install  && \
    tar zxvf /tmp/mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz -C /opt && \
    mkdir -p /opt/mysql && \
    mv /opt/mysql-5.7.25-linux-glibc2.12-x86_64/* /opt/mysql/ && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#install jdk
COPY jdk-8u121-linux-x64.tar.gz /tmp/jdk-8u121-linux-x64.tar.gz
RUN mkdir /opt/jdk  && \
    tar -zxvf /tmp/jdk-8u121-linux-x64.tar.gz -C /opt/jdk --strip-components=1 && \
    echo "export JAVA_HOME=/opt/jdk">>/etc/bashrc && \
    rm -rf /tmp/*


# install pipenv pyenv
ENV PYENV_ROOT=/home/go/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN apt-get update && \
    apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev libbz2-dev libsqlite3-dev libffi-dev jq python-mysql.connector && \
    git clone https://github.com/pyenv/pyenv.git /home/go/.pyenv && \
    echo 'export PYENV_ROOT="/home/go/.pyenv"' >> /home/go/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/go/.bashrc && \
    echo 'if command -v pyenv 1>/dev/null 2>&1; then' >> /home/go/.bashrc && \
    echo '  eval "$(pyenv init -)"' >> /home/go/.bashrc && \
    echo 'fi' >> /home/go/.bashrc && \
    pyenv install 3.7.10 && \
    pyenv rehash && \
    pyenv global 3.7.10 && \
    pip install --upgrade pip && \
    pip install pipenv && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#.net dependency
RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y dirmngr gnupg apt-transport-https ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update && \
    apt-get install -y mono-complete && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#install maven
COPY apache-maven-3.6.3-bin.tar.gz /docker-build/apache-maven-3.6.3-bin.tar.gz
RUN tar -zxvf /docker-build/apache-maven-3.6.3-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-maven-3.6.3 /usr/local/apache-maven && \
    echo "export MAVEN_HOME=/usr/local/apache-maven">>/etc/bashrc

# chmod on ntpdate for SUID privilege
RUN chmod u+s /usr/sbin/ntpdate

#config $PATH with jdk and mvn
RUN echo "export PATH=/opt/jdk/bin:/usr/local/apache-maven/bin:$PATH">>/etc/bashrc

RUN mkdir ~/.ssh
RUN sed -i -e "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN yes 'y'|ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN yes 'y'|ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN yes 'y'|ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''
RUN yes 'y'|ssh-keygen -t rsa -N ""  -f "/root/.ssh/id_rsa"
RUN echo root:sshpass|chpasswd

COPY * /docker-build/

CMD ["/bin/bash"]

