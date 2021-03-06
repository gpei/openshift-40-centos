FROM centos:7

MAINTAINER OpenShift Team <dev@lists.openshift.redhat.com>

USER root

# Add origin repo for including the oc client
COPY origin-extra-root /

# install ansible and deps
RUN INSTALL_PKGS="python-lxml python-dns pyOpenSSL python2-cryptography openssl python2-passlib httpd-tools openssh-clients origin-clients iproute patch google-cloud-sdk git" \
 && yum clean metadata \
 && yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS \
 && EPEL_PKGS="ansible python2-boto python2-crypto which python2-pip.noarch python2-scandir python2-packaging" \
 && yum install -y epel-release \
 && yum install -y --setopt=tsflags=nodocs $EPEL_PKGS \
 && rpm -V $INSTALL_PKGS $EPEL_PKGS $EPEL_TESTING_PKGS \
 && pip install 'apache-libcloud~=2.2.1' 'SecretStorage<3' 'google-auth' \
 && yum clean all

LABEL name="openshift/origin-ansible" \
      summary="OpenShift's installation and configuration tool" \
      description="A containerized openshift-ansible image to let you run playbooks to install, upgrade, maintain and check an OpenShift cluster" \
      url="https://github.com/openshift/openshift-ansible" \
      io.k8s.display-name="openshift-ansible" \
      io.k8s.description="A containerized openshift-ansible image to let you run playbooks to install, upgrade, maintain and check an OpenShift cluster" \
      io.openshift.expose-services="" \
      io.openshift.tags="openshift,install,upgrade,ansible" \
      atomic.run="once" \
      commit="e1d4d6f09"

ENV USER_UID=1001 \
    HOME=/opt/app-root/src \
    WORK_DIR=/usr/share/ansible/openshift-ansible \
    OPTS="-v"

# Add image scripts and files for running as a system container
COPY root /

RUN git clone -b devel-40-ci-test https://github.com/vrutkovs/openshift-ansible /usr/share/ansible/openshift-ansible
RUN /usr/local/bin/user_setup

USER ${USER_UID}

WORKDIR ${WORK_DIR}
ENTRYPOINT [ "/usr/local/bin/entrypoint-gcp" ]
CMD [ "/usr/local/bin/run" ]
