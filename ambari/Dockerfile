FROM centos:6.6

MAINTAINER Luciano Resende <lresende@apache.org>

USER root

RUN yum install -y awk curl openssh-server openssh-clients openssl rsync ntpd sudo tar wget which #openssl-1.0.1e-16.el6.x86_64
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN mkdir -p /root/.ssh
ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 644 /root/.ssh/id_rsa.pub
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# update root password
RUN echo 'root:passw0rd' | chpasswd

# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-7u71-linux-x64.rpm
RUN rm jdk-7u71-linux-x64.rpm
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# dnsmasq
RUN yum install -y dnsmasq
ADD config /etc

# ambari
RUN wget -O /etc/yum.repos.d/ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.7.0/ambari.repo
RUN yum -y install ambari-server
RUN ambari-server setup --silent

# ambari agent
RUN yum -y install ambari-agent
ADD ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini
#RUN echo "PYTHON=/usr/bin/python2.6" >> /var/lib/ambari-agent/ambari-env.sh

# ambari server setup
RUN ambari-server setup --silent

# bootstrap config
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

EXPOSE 2122 4080 50010 50020 50030 50070 50075 50090 50111 8000 8020 8021 8080 8088 8443 8670 8888

CMD ["/etc/bootstrap.sh", "-bash"]
