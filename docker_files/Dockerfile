FROM rockylinux:9

LABEL org.opencontainers.image.title="slurm-mini-cluster" \
      org.opencontainers.image.description="Slurm Docker cluster on Rocky Linux 9" \
      org.label-schema.docker.cmd="docker-compose up -d" 

RUN set -x \
    && export MUNGEUSER=1005 \
    && groupadd -g $MUNGEUSER munge \
    && useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge \
    && export SlurmUSER=1001 \
    && groupadd -g $SlurmUSER slurm \
    && useradd  -m -c "Slurm workload manager" -d /var/lib/slurm -u $SlurmUSER -g slurm  -s /bin/bash slurm 

RUN set -ex \
    && dnf makecache \
    && dnf -y update \
    && dnf install -y dnf-plugins-core \ 
    && dnf config-manager --set-enabled crb \
    && dnf -y install epel-release \ 
    && dnf clean all \
    && dnf -y install mariadb-server mariadb-devel wget \ 
    && dnf -y install rpm-build gcc python3 openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel gtk2-devel libibmad libibumad perl-Switch perl-ExtUtils-MakeMaker xorg-x11-xauth dbus-devel libbpf bash-completion \ 
    && dnf -y install munge munge-libs munge-devel \ 
    && dnf -y install libssh2-devel man2html \ 
    && dnf -y install http-parser-devel json-c-devel libjwt-devel jq \
    && dnf -y install libyaml-devel \  
    && dnf -y install nano autoconf automake \
    && rm -rf /var/lib/apt/lists/* \ 
    && dnf clean all \
    && rm -rf /var/cache/yum

# gosu is needed because we are in a container environment
ARG GOSU_VERSION=1.17
RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x  \ 
    && dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key \
    && chown munge:munge /etc/munge/munge.key \
    && chmod 400 /etc/munge/munge.key \ 
    && chown -R munge:munge  /etc/munge/ /var/log/munge/ \ 
    && chmod 0700 /etc/munge/ /var/log/munge/

ARG SLURM_TAG

RUN set -x \
    && cd / \
    && wget https://download.schedmd.com/slurm/slurm-${SLURM_TAG}.tar.bz2 \
    && rpmbuild -ta slurm-${SLURM_TAG}.tar.bz2 --with mysql --with slurmrestd --with yaml 

RUN set -x \
    # slurmctld items 
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-devel-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-perlapi-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-torque-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-example-configs-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-slurmctld-${SLURM_TAG}*rpm \
    ## && systemctl enable slurmctld \ 
    && mkdir -p /var/spool/slurmctld /var/log/slurm \ 
    && chown slurm:slurm /var/spool/slurmctld /var/log/slurm \
    && chmod 755 /var/spool/slurmctld /var/log/slurm \
    && touch /var/log/slurm/slurmctld.log \ 
    && chown slurm:slurm /var/log/slurm/slurmctld.log 
    ## dnf install slurm-slurmrestd-$VER*rpm # can add this 

RUN set -x \
    # slurmd items 
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-slurmd-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-pam_slurm-${SLURM_TAG}*rpm \
    ## systemctl enable slurmd
    && mkdir -p /var/spool/slurmd /var/log/slurm \
    && chown slurm:slurm /var/spool/slurmd  /var/log/slurm \
    && chmod 755 /var/spool/slurmd  /var/log/slurm \
    && touch /var/log/slurm/slurmd.log \
    && chown slurm:slurm /var/log/slurm/slurmd.log 
    ## dnf install slurm-libpmi-$VER*rpm  can install this too for PMIx 

RUN set -x \
    # slurmdbd stuff
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-${SLURM_TAG}*rpm \ 
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-devel-${SLURM_TAG}*rpm \
    && dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-slurmdbd-${SLURM_TAG}*rpm \
    && mkdir -p /var/log/slurm \
    && touch /var/log/slurm/slurmdbd.log \ 
    && chown slurm:slurm /var/log/slurm /var/log/slurm/slurmdbd.log \ 
    && chmod 750 /var/log/slurm \
    && chmod 640 /var/log/slurm/slurmdbd.log 

RUN set -x \
    ## systemctl enable slurmdbd 
    # login node items
    #&& dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-${SLURM_TAG}*rpm \
    #&& dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-devel-${SLURM_TAG}*rpm \ 
    #&& dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-contribs-${SLURM_TAG}*rpm \
    #&& dnf -y install /root/rpmbuild/RPMS/x86_64/slurm-perlapi-${SLURM_TAG}*rpm \
#    && groupadd -r --gid=990 slurm \
#    && useradd -r -g slurm --uid=990 slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \ 
        /data \ 
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* 
#    && /sbin/create-munge-key

COPY ./slurm_files/slurm.conf /etc/slurm/slurm.conf
COPY ./slurm_files/slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY ./slurm_files/cgroup.conf /etc/slurm/cgroup.conf
COPY ./slurm_files/job_submit.lua /etc/slurm/job_submit.lua

RUN set -x \
    && chown slurm:slurm /etc/slurm/slurmdbd.conf \
    && chmod 600 /etc/slurm/slurmdbd.conf \ 
    && chown slurm:slurm /etc/slurm/cgroup.conf \
    && chmod 600 /etc/slurm/cgroup.conf \ 
    && chown slurm:slurm /etc/slurm/job_submit.lua \
    && chmod 600 /etc/slurm/job_submit.lua


COPY ./docker_files/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["slurmdbd"]
