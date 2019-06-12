#https://github.com/sclorg/s2i-php-container/blob/master/7.2/Dockerfile
FROM centos/php-72-centos7
ARG APACHE_LOGS
USER root

#Install Enterprise Linux repos and update packages
RUN rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
RUN yum install -y https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    https://rpms.remirepo.net/enterprise/remi-release-7.rpm && yum-config-manager --enable remi-php72 >/dev/null
RUN yum update -y

#Repo for Microsoft ODBC Driver, required for mssql
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

# Install Extra packages - custom-init script for loading of non-default packages
RUN INSTALL_PKGS="sclo-php72-php-pecl-geoip sclo-php72-php-pecl-igbinary sclo-php72-php-pecl-imagick \
                  sclo-php72-php-pecl-memcached rh-php72-php-odbc sclo-php72-php-tidy rh-php72-php-xmlrpc \
                  msodbcsql17 php-sqlsrv sclo-php72-php-pecl-ssh2 sclo-php72-php-pecl-xdebug vim-enhanced" && \
    ACCEPT_EULA=Y yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS --nogpgcheck && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy custom_init script to the image before running our custom initialisation steps
COPY ./root/ /
RUN /usr/libexec/custom-init

# Run apache - Check the container details from source link above for details of the run/setup scripts
CMD $STI_SCRIPTS_PATH/run
