#!/bin/bash
# Likely to be broken...
# ssh keys, ssl certs and repository should be uploaded first

set -e

function benchmark(){
    cpu_core=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
    cpu_freq=`grep -oP -m 1 "MHz[^\d]*\K[0-9\.]*" /proc/cpuinfo 2>/dev/null`
    mem_info=`free -mh | grep -oP "Mem[^\d]* \K[0-9\.]*[GM]" 2>/dev/null`
    disk=`dd if=/dev/zero of=test bs=16k count=8k conv=fdatasync 2>&1 | grep -o "[0-9\.]* MB/s$" 2>/dev/null`

    rm test
    echo "CPU number of cores:  $cpu_core"
    echo "CPU frequency (MHz):  $cpu_freq"
    echo "Memory:               $mem_info"
    echo "IO:                   $disk"
}

function configure_common_software(){
    apt-get update
    apt-get upgrade
    apt-get install aptitude # always prefer aptitude :)

    # no-recommends
    echo "APT::Install-Recommends '0';" > /etc/apt/apt.conf
    echo "APT::Install-Suggests '0';" >> /etc/apt/apt.conf
    echo "APT::AutoRemove::RecommendsImportant 'false';" >> /etc/apt/apt.conf
    echo "APT::AutoRemove::SuggestsImportant 'false';" >> /etc/apt/apt.conf
    apt-get autoremove

    # common softwares
    apt-get purge xinet* apache* php* mysql* samba* sendmail* procmail* fetchmail* mailx* exim* bind9* sasl2-bin
    aptitude install dbus # possible missing
    aptitude install libpcre3 whiptail e2fsprogs # may not default (grep -P)
    aptitude install unattended-upgrades tzdata locales cron sudo rsync curl git # critical
    aptitude install bash-completion less vim # tools
}

function configure_common_system(){
    dpkg-reconfigure -plow unattended-upgrades # automatic upgrades
    sed -i 's/^\/\/\(.*Reboot "\)false/\1true/' /etc/apt/apt.conf.d/50unattended-upgrades # auto reboot
    if [[ -f /etc/cron.daily/apt.disabled ]];then # fix possible broken templates
        mv /etc/cron.daily/apt.disabled /etc/cron.daily/apt
    fi
    chmod +x /etc/cron.daily/apt # fix possible broken templates

    # localization
    dpkg-reconfigure tzdata
    dpkg-reconfigure locales

    # hostname
    current=`hostname`
    sed -i "s/$current/$HOSTNAME/" /etc/hostname
    sed -i "s/$current/$HOSTNAME/" /etc/hosts
    if [[ -n `grep "127.0.0.1" /etc/hosts` ]]; then
        sed -i "s/\(127\.0\.0\.1\s*\).*/\1$HOSTNAME/" /etc/hosts
    fi
    hostnamectl set-hostname $HOSTNAME

    # accounts
    echo ">>>>>>set password for ROOT:"
    passwd
    echo ">>>>>>set account for $USERNAME:"
    adduser $USERNAME

    # ssh on login user
    sudo -u $USERNAME ssh-keygen -t rsa
    cp /root/id_rsa.pub /home/$USERNAME/.ssh/authorized_keys
    chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/*

    # ssh server
    conf="Protocol 2\nPort $SSHDPORT\n"
    conf="$conf\nChallengeResponseAuthentication no\nPasswordAuthentication no\nPermitRootLogin no\nServerKeyBits 2048\n"
    conf="$conf\nAllowGroups $USERNAME\nAllowUsers $USERNAME\n"
    conf="$conf\nSubsystem sftp /usr/lib/openssh/sftp-server"
    echo -e $conf > /etc/ssh/sshd_config
    systemctl restart ssh

    # persistent systemd journal
    mkdir -p /var/log/journal/
}

function configure_common_person(){
    CRONTIME=$1

    # retrive repository
    mv /home/root/repository /home/$USERNAME/

    # configuration for normal user
    cd /home/$USERNAME && sudo -u $USERNAME find repository/dotfiles/ -maxdepth 1 -mindepth 1 -exec ln -sf {} . \;

    # configuration for root
    cp -r /home/$USERNAME/repository/dotfiles/.vim* /root/
    cp -r /home/$USERNAME/repository/dotfiles/.bashrc /root/

    # fix permissions
    chown -R $USERNAME:$USERNAME /home/$USERNAME
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/*

    # backup
    command="$CRONTIME /home/$USERNAME/bin/archive.sh &> /dev/null"
    (echo "$command") | crontab -u $USERNAME -
}

function configure_protection_iptables(){
    PORTS=($1)

    conf="iptables -F\niptables -X\niptables -A INPUT -i lo -j ACCEPT"
    conf="$conf\niptables -A INPUT -i '!lo' -d 127.0.0.0/8 -j REJECT\niptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"
    for port in ${PORTS[*]}; do
        conf="$conf\niptables -A INPUT -p tcp --dport $port -j ACCEPT"
    done
    conf="$conf\niptables -A INPUT -p tcp -m state --state NEW --dport $SSHDPORT -j ACCEPT"
    conf="$conf\niptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT"
    conf="$conf\niptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix 'iptables denied: ' --log-level 4"
    conf="$conf\niptables -A INPUT -j DROP\niptables -A OUTPUT -j ACCEPT\niptables -A FORWARD -j DROP\n"
    conf="$conf\nip6tables -F\nip6tables -X\nip6tables -A INPUT -i lo -j ACCEPT"
    conf="$conf\nip6tables -A INPUT -i '!lo' -d ::1/128 -j REJECT\nip6tables -A INPUT -p tcp -m tcp ! --syn -j ACCEPT"
    for port in ${PORTS[*]}; do
        conf="$conf\nip6tables -A INPUT -p tcp --dport $port -j ACCEPT"
    done
    conf="$conf\nip6tables -A INPUT -p tcp --dport $SSHDPORT -j ACCEPT"
    conf="$conf\nip6tables -A INPUT -p icmpv6 -j ACCEPT"
    conf="$conf\nip6tables -A INPUT -j DROP\nip6tables -A OUTPUT -j ACCEPT\nip6tables -A FORWARD -j DROP"
    echo -e $conf > /etc/iptables.sh
    chmod +x /etc/iptables.sh
    sh /etc/iptables.sh

    sed -i "s|exit 0|sh /etc/iptables.sh\nexit 0|" /etc/rc.local
    cp -r /home/$USERNAME/repository/system/systemd/iptables.service /etc/systemd/system/
    systemctl enable iptables.service
    systemctl start iptables.service
}

function configure_protection_ufw(){
    PORTS=($1)

    aptitude install ufw
    ufw enable
    ufw allow $SSHDPORT
    for port in ${PORTS[*]}; do
        ufw allow $port
    done
}

function configure_encryption_letsencrypt(){
    CRONTIME=$1
    ROOTNAME=$2
    CERTFILE=/etc/letsencrypt/live

    aptitude install certbot

    cp -r /home/$USERNAME/repository/system/letsencrypt/cli.ini /etc/letsencrypt/cli.ini
    mkdir -p $HTTPHOME/letsencrypt && chown -R $HTTPUSER:$HTTPUSER $HTTPHOME/letsencrypt
    certbot certonly

    addgroup certificate
    chown -R root:root /etc/letsencrypt
    chown root:certificate $CERTFILE
    chmod 750 $CERTFILE

    command="$CRONTIME certbot certonly && cat $CERTFILE/$ROOTNAME/privkey.pem $CERTFILE/$ROOTNAME/fullchain.pem > $CERTFILE/$ROOTNAME/$ROOTNAME.pem"
    (echo "$command") | crontab -u root -
}

function configure_http_memcached(){
    aptitude install memcached

    cp -r /home/$USERNAME/repository/system/memcached/memcached.conf /etc/memcached.conf
    systemctl restart memcached
}

function configure_http_mysql(){
    aptitude install mysql-server mysql-client

    cp -r /home/$USERNAME/repository/system/mysql/my.cnf /etc/mysql/my.cnf
    systemctl restart mysql

    # security
    mysql_secure_installation

    # database backup
    echo "MYSQL: password for root"
    query="GRANT LOCK TABLES, SELECT ON *.* TO backupuser@localhost;"
    mysql -u root -p -e "$query"
}

function configure_http_php(){
    aptitude install php-cgi php-cli php-fpm php-gd php-curl # php essentials
    aptitude install php-mbstring
    if [[ -f /usr/bin/memcached ]]; then
        aptitude install php-memcache php-memcached
    fi
    if [[ -f /usr/bin/mysql ]]; then
        aptitude install php-mysqlnd
    fi

    rm -rf /etc/php/7.0/*
    cp -r /home/$USERNAME/repository/system/php/* /etc/php/7.0/
    systemctl restart php7.0-fpm
}

function configure_http_nginx(){
    CRONTIME=$1

    aptitude install nginx # web server

    rm -rf /etc/nginx/*
    cp -r /home/$USERNAME/repository/system/nginx/* /etc/nginx/
    systemctl restart nginx

    mkdir -p $HTTPHOME
    chown root:$HTTPUSER $HTTPHOME

    command="$CRONTIME systemctl restart nginx"
    (echo "$command") | crontab -u root -
}

function configure_http_imageopt(){
    CRONTIME=$1

    aptitude install optipng gifsicle jpegoptim # image optimization

    mkdir -p $HTTPHOME/bin/
    cp /home/$USERNAME/repository/http/bin/imageopt.sh $HTTPHOME/bin/
    chown -R $HTTPUSER:$HTTPUSER $HTTPHOME/bin/
    command="$CRONTIME bash $HTTPHOME/bin/imageopt.sh &> /dev/null"
    (echo "$command") | crontab -u $HTTPUSER -
}

function configure_http_binding(){
    rm -rf /home/$USERNAME/repository/http
    mkdir -p /home/$USERNAME/repository/http
    mount --bind $HTTPHOME /home/$USERNAME/repository/http
    echo "$HTTPHOME /home/$USERNAME/repository/http none bind 0 0" >> /etc/fstab
}

function configure_application_wordpress(){
    DATABASE=$1
    HTTPROOT=$2

    # create database table
    echo "MYSQL: password for $USERNAME"
    read -s password
    echo "MYSQL: password for root"
    query="CREATE DATABASE $DATABASE DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    query="$query GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON luyuancw.* TO $USERNAME@localhost IDENTIFIED BY '$password';"
    query="$query USE $DATABASE;"
    query="$query SOURCE /home/$USERNAME/repository/database/$DATABASE.sql;"
    mysql -u root -p -e "$query"

    # wordpress site
    mkdir -p $HTTPHOME/$HTTPROOT
    rsync -va /home/$USERNAME/repository/http/$HTTPROOT/ $HTTPHOME/$HTTPROOT/
    echo -e "<?php\ndefine('DB_PASSWORD', '');" > $HTTPHOME/$HTTPROOT/wp-config-sec.php
    vim $HTTPHOME/$HTTPROOT/wp-config-sec.php

    # wordpress permissions
    chown -R $HTTPUSER:$HTTPUSER $HTTPHOME/$HTTPROOT
    chmod -R 755 $HTTPHOME/$HTTPROOT
    find $HTTPHOME/$HTTPROOT -type f -exec chmod 644 {} \;
    chmod 640 $HTTPHOME/$HTTPROOT/wp-config-sec.php
}

function configure_application_dokuwiki(){
    HTTPROOT=$1
    CRONTIME=$2

    # dokuwiki site
    mkdir -p $HTTPHOME/$HTTPROOT
    rsync -va /home/$USERNAME/repository/http/$HTTPROOT/ $HTTPHOME/$HTTPROOT/
    mkdir -p $HTTPHOME/$HTTPROOT/data/{attic,media_attic,cache,index,locks,tmp}
    cd $HTTPHOME/$HTTPROOT/bin && php indexer.php

    # dokuwiki cron
    command="$CRONTIME bash $HTTPHOME/$HTTPROOT/bin/cleanwiki.sh &> /dev/null"
    (echo -e "$command") | crontab -u $HTTPUSER -

    # dokuwiki permissions
    chown -R $HTTPUSER:$HTTPUSER $HTTPHOME/$HTTPROOT
    chmod -R 755 $HTTPHOME/$HTTPROOT
    find $HTTPHOME/$HTTPROOT -type f -exec chmod 644 {} \;
}

function configure_application_shadowsocks(){
    PORT=$1

    aptitude install shadowsocks-libev

    addr=`curl --ipv4 -s icanhazip.com 2>/dev/null`
    echo "Please enter the server pass:"
    read -s pass
    conf="{\n\"server\":\"$addr\",\n\"server_port\":$PORT,\n\"password\":\"$pass\",\n\"timeout\":600,\n\"method\":\"aes-256-gcm\",\n}"
    echo -e $conf > /etc/shadowsocks-libev/config.json

    systemctl restart shadowsocks-libev
}

function configure_application_git(){
    SAFEMODE=$1
    BAREREPO=($2)

    # add restricted user
    if [[ -z `grep "git-shell" /etc/shells` ]]; then
        echo "/usr/bin/git-shell" >> /etc/shells
    fi
    adduser --shell /usr/bin/git-shell --disabled-password git

    # add ssh permission
    sed -i "s/$USERNAME/$USERNAME git/" /etc/ssh/sshd_config
    systemctl restart ssh

    # prepare to accepting keys
    sudo -u git mkdir -p /home/git/.ssh
    sudo -u git touch /home/git/.ssh/authorized_keys
    chmod 700 /home/git/.ssh
    chmod 600 /home/git/.ssh/authorized_keys

    # prevent force push and branch deletion
    if [[ "$SAFEMODE" == "TRUE" ]]; then
        sudo -u git git config --global receive.denyNonFastforwards true
        sudo -u git git config --global receive.denyDeletes true
    fi

    # init bare repo
    for repo in ${BAREREPO[*]}; do
        cd /home/git && sudo -u git mkdir -p $repo.git
        cd /home/git/$repo.git && sudo -u git git init --bare
    done
}

function configure_application_bitlbee(){
    aptitude install bitlbee
    sed -i 's|^#.*DaemonInterface.*=.*|DaemonInterface = 127\.0\.0\.1|' /etc/bitlbee/bitlbee.conf
    systemctl restart bitlbee
}

function configure_application_weechat_client(){
    HTTPROOT=$1

    cd $HTTPHOME
    git clone https://github.com/glowing-bear/glowing-bear.git $HTTPROOT
    chown -R $HTTPUSER:$HTTPUSER $HTTPROOT
    echo -e "User-agent: *\nDisallow: /" > $HTTPROOT/robots.txt
}

function configure_application_weechat_server(){
    CRONTIME=$1

    aptitude install screen weechat weechat-plugins

    adduser --disabled-password weechat
    usermod -a -G certificate weechat

    echo "term screen-256color" > /home/weechat/.screenrc
    chown weechat:weechat /home/weechat/.screenrc

    mkdir -p /home/weechat/.weechat
    cp -r /home/$USERNAME/repository/system/weechat/* /home/weechat/.weechat/
    chown -R weechat:weechat /home/weechat/.weechat
    chmod 644 /home/weechat/.weechat/*.conf

    # autostart
    echo "Password to start weechat"
    read -s password
    echo "$password" > /home/weechat/.weechat-passphrase
    chown weechat:weechat /home/weechat/.weechat-passphrase
    chmod 600 /home/weechat/.weechat-passphrase
    cp -r /home/$USERNAME/repository/system/systemd/weechat.service /etc/systemd/system/
    systemctl start weechat
    systemctl enable weechat

    command="$CRONTIME systemctl restart weechat"
    (echo "$command") | crontab -u root -
}

function configure_server_sites(){
    DOMAINNM=lainme.com

    configure_common_person "0 0 * * 0" "$DOMAINNM"
    configure_protection_iptables "80 443"
    configure_encryption_letsencrypt "0 0 1 * *" "$DOMAINNM"
    configure_http_php
    configure_http_nginx "0 1 1 * *"
    configure_application_dokuwiki "$DOMAINNM" "0 1 * * 0"
    configure_http_imageopt "0 2 * * 0"
    configure_http_binding
}

function configure_server_shadowsocks(){
    echo "Please enter the server port:"
    read -s port
    configure_protection_iptables "$port"
    configure_application_shadowsocks "$port"
}

function configuration(){
    configure_common_software
    configure_common_system
    configure_server_${HOSTNAME#server-}
}

# defaults
USERNAME=lainme
HTTPUSER=www-data
HTTPHOME=/srv/http
SSHDPORT=21
# server choice
HOSTNAME=server-sites

echo "Please enter SSH port:"
read SSHDPORT

$@
