FROM centos/systemd

ENV term=xterm
ENV container docker

RUN yum install -y deltarpm
RUN yum update -y
RUN yum install -y systemd-libs epel-release yum-tools autofs nfs-utils ca-certificates man

RUN yum install -y \
vim-enhanced-7.4.160-2.el7.x86_64 \ 
nano-2.3.1-10.el7.x86_64 \
less-458-9.el7.x86_64 \
expect-5.45-14.el7_1 \ 
curl-7.29.0-42.el7.x86_64 \
wget-1.14-15.el7_4.1.x86_64 \
ftp-0.17-67.el7 \
jq-1.5-1.el7.x86_64 \ 
openssh-clients-7.4p1-13.el7_4 \
net-tools-2.0-0.22.20131004git.el7.x86_64 \
traceroute-2.0.22-2.el7.x86_64 \
iproute-3.10.0-87.el7.x86_64 \
bind-utils-9.9.4-51.el7_4.2  \
unzip-6.0-16.el7.x86_64 \
zip-3.0-11.el7.x86_64 \
bzip2-1.0.6-13.el7.x86_64 

#python34-setuptools-19.2-3.el7.noarch \
#python34-pip-8.1.2-5.el7.noarch 

#### SYSTEMD
VOLUME ["/run"]

RUN systemctl mask \ 
dev-mqueue.mount \
dev-hugepages.mount \
systemd-remount-fs.service \
sys-kernel-config.mount \
sys-kernel-debug.mount \
sys-fs-fuse-connections.mount \
display-manager.service \
systemd-logind.service

# need to figure out if this service is needed
# https://bugzilla.redhat.com/show_bug.cgi?id=1472439
RUN systemctl mask systemd-machine-id-commit.service
#

RUN systemctl disable graphical.target systemd-tmpfiles-clean.timer
RUN systemctl enable multi-user.target

# TODO: DOCUMENT WHY
ADD dbus.service /etc/systemd/system/dbus.service
RUN systemctl enable dbus.service

# to deal with an autofs bug https://bugzilla.redhat.com/show_bug.cgi?id=1489648
# supposedly fixed in newer autofs ver autofs-5.0.7-73.el7/
RUN yum install -y libsss_autofs

# CMD  ["/usr/sbin/init"]
#### END OF SYSTEMD

#### AUTOFS
# Note the autofs.service is not set to enable in systemd
# this is because we will first create its config file on startup
# using ??? systemd service
RUN mkdir /autofs
RUN echo "/autofs /etc/auto.misc --timeout=0" >> /etc/auto.master
RUN echo "test -rw 172.31.7.236:/nfsshare" >> /etc/auto.misc

COPY configure-nfs.sh /configure-nfs.sh
RUN chmod 777 /configure-nfs.sh
RUN chmod +x /configure-nfs.sh
####

## not used yum install -y # mc git openssl nmap gcc-4.8.5-16.el7_4.1 

#### PYTHON
#RUN pip3 install --upgrade pip
#RUN pip3 install virtualenv
####

#### JAVA 1.9
# per http://jdk.java.net/9/
# RUN curl -L -O https://download.java.net/java/GA/jdk9/9.0.4/binaries/openjdk-9.0.4_linux-x64_bin.tar.gz
# RUN tar xvf openjdk-9.*_bin.tar.gz -C /opt
# ENV JAVA_HOME /opt/jdk-9.0.4
# ENV PATH=$PATH:$JAVA_HOME/bin
# takes a lot of space, is it needed? # yum install -y pki-base-java pki-tools
#### 

#### RUN yum clean all

### LAB WORK
# systemd wants to be process ID 1, and the mesos containerizer does its own init
# process, thus it takes up PID 1. systemd wasn't intended to be in a container.
# this is for a POC lab and the final production use case may not even need/want systemd
# I'm using systemd since it's handy and I know it. https://github.com/krallin/tini may be used instead.
# https://hackernoon.com/the-curious-case-of-pid-namespaces-1ce86b6bc900
# and https://www.freedesktop.org/software/systemd/man/systemd.html
CMD  ["/usr/lib/systemd/systemd", "--system"]
