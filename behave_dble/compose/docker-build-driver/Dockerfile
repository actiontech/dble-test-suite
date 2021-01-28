From ubuntu:18.04
RUN apt-get update
RUN apt-get -y install curl wget vim build-essential libboost1.65-dev gdb git cmake libmysqlclient-dev libyaml-cpp-dev openssh-server iptables
RUN wget -P /opt https://dev.mysql.com/get/Downloads/Connector-C++/mysql-connector-c++-1.1.11.tar.gz
RUN tar zxvf /opt/mysql-connector-c++-1.1.11.tar.gz -C /opt/
RUN sed -i -e '/list(APPEND SYS_LIBRARIES "mysql_sys")/d' /opt/mysql-connector-c++-1.1.11/FindMySQL.cmake
RUN sed -i -e '/list(APPEND SYS_LIBRARIES "mysql_strings")/d' /opt/mysql-connector-c++-1.1.11/FindMySQL.cmake
RUN cd /opt/mysql-connector-c++-1.1.11/ &&\
    cmake .; make -j 3; make install
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib">>/root/.bashrc
RUN wget -P /opt https://github.com/jbeder/yaml-cpp/archive/release-0.5.1.tar.gz
RUN tar zxvf /opt/release-0.5.1.tar.gz -C /opt/ &&\
    mkdir /opt/yaml-cpp-release-0.5.1/build
RUN cd /opt/yaml-cpp-release-0.5.1/build &&\
    cmake -DBUILD_SHARED_LIBS=ON ..;make -j 3;make install
RUN tar zxvf /opt/mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz -C /opt && \
     mkdir -p /opt/mysql && \
     mv /opt/mysql-5.7.13-linux-glibc2.5-x86_64/* /opt/mysql/
RUN mv /opt/mysql-connector-c++-1.1.11.tar.gz /docker-build/. && \
    mv /opt/release-0.5.1.tar.gz /docker-build/.
RUN mkdir ~/.ssh
RUN sed -i -e "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN apt-get install -y sshpass
RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''
RUN ssh-keygen -t rsa -N ""  -f "/root/.ssh/id_rsa"
RUN echo root:sshpass|chpasswd

COPY * /docker-build/

CMD ["/bin/bash"]
