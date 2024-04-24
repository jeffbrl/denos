# DenOS - Debian Linux build from scratch with Debootstrap#
# Bernardino Lopez [ bernardino.lopez@gmail.com ]
# 11.27.18

# Modified by Jeff Loughridge

# 03_denos_chroot_nfs.sh - Customize your Distro
# Preps system for NFS booting including NFS /home
# As root in chroot. Execute the script in a Terminal
# ./03_denos_chroot_nfs.sh

# export LIVE_BOOT=LIVE_BOOT64
source ./denos_config.txt

#  > /etc/hostname
echo $DISTRO_HOSTNAME > /etc/hostname

apt-cache search linux-image

apt-get update && \
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv \
    nfs-common

apt-get install -y --no-install-recommends \
    curl openssh-server openssh-client \
    iputils-ping \
    htop nmap wget git ca-certificates \
    nano fdisk && \
apt-get clean

echo -e "127.0.0.1\tlocalhost" > /etc/hosts
echo -e "127.0.0.1\t$DISTRO_HOSTNAME" >> /etc/hosts

# Create live user
#useradd -m live -s /bin/bash
# Change user live password to : newpassword
#echo 'jeffl:sprint26' | chpasswd

passwd root

cat << EOF > /etc/fstab
proc    /proc   proc    defaults        0 0
/dev/nfs        /       nfs     tcp,nolock      0 0
none    /tmp    tmpfs   defaults        0 0
none    /var/tmp        tmpfs   defaults        0 0
none    /var/log        tmpfs   defaults        0 0
$NFS_SERVER:$PATH_TO_NFS_HOME   /home   nfs     tcp,nolock      0 0
EOF

locale-gen LANG=en_US.UTF-8
locale-gen --purge "en_US.UTF-8"
dpkg-reconfigure --frontend noninteractive locales

apt install -y firmware-linux-free

cat << EOF > /etc/initramfs-tools/initramfs.conf
MODULES=netboot
BUSYBOX=y
KEYMAP=n
COMPRESS=gzip
DEVICE=
NFSROOT=auto
BOOT=nfs
EOF

update-initramfs -u
echo ASYNMOUNTNFS=no >> /etc/default/rcS
echo RAMTMP=yes >> /etc/default/tmpfs

exit
