#https://github.com/sclorg/s2i-php-container/blob/master/7.3/Dockerfile
FROM centos/php-73-centos7
ARG APACHE_LOGS
USER root

#Install Enterprise Linux repos and update packages
RUN rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
RUN yum install -y https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    https://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum-config-manager --enable remi-php73 >/dev/null
RUN yum update -y

#Repo for Microsoft ODBC Driver, required for mssql
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

# Install Extra packages - custom-init script for loading of non-default packages
RUN INSTALL_PKGS="sclo-php73-php-pecl-geoip sclo-php73-php-pecl-igbinary sclo-php73-php-pecl-imagick \
                  sclo-php73-php-pecl-memcached libsodium sclo-php73-php-sodium sclo-php73-php-pecl-ssh2 \
                  sclo-php73-php-tidy sclo-php73-php-pecl-uuid \
                  rh-php73-php-odbc rh-php73-php-xmlrpc \
                  msodbcsql17 php-sqlsrv \
                  rh-php73-php-pecl-xdebug \
                  vim-enhanced" && \
    ACCEPT_EULA=Y yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS --nogpgcheck && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy custom_init script to the image before running our custom initialisation steps
COPY ./root/ /
RUN /usr/libexec/custom-init

# Run apache - Check the container details from source link above for details of the run/setup scripts
CMD $STI_SCRIPTS_PATH/run
