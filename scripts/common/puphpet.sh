#!/usr/bin/env bash

set -eux

groupadd www-data || true
useradd -g www-data www-data || true

mkdir -p /.puphpet-stuff/shell

wget --quiet --tries=5 --connect-timeout=10 --no-check-certificate -O /.puphpet-stuff/shell/os-detect.sh https://raw.githubusercontent.com/puphpet/puphpet/box-generation/archive/puphpet/shell/os-detect.sh
wget --quiet --tries=5 --connect-timeout=10 --no-check-certificate -O /.puphpet-stuff/shell/initial-setup.sh https://raw.githubusercontent.com/puphpet/puphpet/box-generation/archive/puphpet/shell/initial-setup.sh
wget --quiet --tries=5 --connect-timeout=10 --no-check-certificate -O /.puphpet-stuff/shell/install-puppet.sh https://raw.githubusercontent.com/puphpet/puphpet/box-generation/archive/puphpet/shell/install-puppet.sh

chmod +x /.puphpet-stuff/shell/os-detect.sh
chmod +x /.puphpet-stuff/shell/initial-setup.sh
chmod +x /.puphpet-stuff/shell/install-puppet.sh

OS=$(/bin/bash /.puphpet-stuff/shell/os-detect.sh ID)

if "${OS}" == 'centos'; then
    yum clean metadata
    yum -y update
fi

/bin/bash /.puphpet-stuff/shell/initial-setup.sh /.puphpet-stuff || true
/bin/bash /.puphpet-stuff/shell/install-puppet.sh || true

if "${OS}" == 'centos'; then
    yum clean metadata
    yum -y update

    yum -y install dkms
    yum -y install fuse fuse-libs fuse-devel

    yum -y install https://github.com/DigiACTive/digiactive-repo/raw/master/centos/6/x86_64/bindfs-1.12.3-1.el6.x86_64.rpm
    yum -y install https://github.com/DigiACTive/digiactive-repo/raw/master/centos/6/x86_64/bindfs-debuginfo-1.12.3-1.el6.x86_64.rpm

    cd /root
    wget --quiet --tries=5 --connect-timeout=10 -O /root/putty-0.67.tar.gz \
        https://the.earth.li/~sgtatham/putty/latest/putty-0.67.tar.gz
    tar -vxzf putty-0.67.tar.gz
    cd putty-0.67
    ./configure --prefix=/opt/putty/ --exec-prefix=/opt/putty
    make
    make install

    ln -s /opt/putty/bin/puttygen /usr/bin/puttygen
else
    apt-get install -y putty-tools
fi
