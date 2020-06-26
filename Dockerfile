#FROM registry.access.redhat.com/ubi8/ubi
FROM centos:7

ENV ansible_dir=/root/JetSki/ansible-ipi-install

RUN yum -y install python3
RUN pip3 install ansible
RUN yum -y install epel-release
RUN yum --enablerepo=epel -y install sshpass
RUN yum -y install openssh-clients
RUN yum -y install git
RUN pip3 install jmespath

# Hammercli
# epel-release is needed, but was installed above.
RUN yum install -y epel-release \
    https://yum.theforeman.org/releases/2.1/el7/x86_64/foreman-release.rpm \
    centos-release-scl-rh \
    rh-ruby25-ruby

RUN yum install -y tfm-rubygem-hammer_cli \
    tfm-rubygem-hammer_cli_foreman

RUN pip3 install j2cli

#COPY ansible-ipi-install /root/ansible-ipi-install
ADD https://api.github.com/repos/jaredoconnell/JetSki/git/refs/heads/containerized version.json
RUN git clone --single-branch --branch centos-7 https://github.com/jaredoconnell/JetSki.git /root/JetSki

#CMD ansible-playbook /install/ansible-ipi-install/prep_kni_user.yml

# Done with hammercli. Next badfish
# Source: https://github.com/redhat-performance/badfish/blob/master/Dockerfile

RUN git clone https://github.com/redhat-performance/badfish /root/badfish

WORKDIR /root/badfish
RUN pip3 install -r requirements.txt
RUN python3 setup.py build
RUN python3 setup.py install

# Done. Now run it.

ENTRYPOINT ansible-playbook -vvv -i $ansible_dir/inventory/jetski/hosts $ansible_dir/playbook-jetski.yml
#ENTRYPOINT /bin/bash

