FROM mysql:5.7
ARG MYSQL_LOGS

# Copy our container setup files
COPY ./root/ /
# Run custom init script
RUN /tmp/mysql/00-custom-init.sh
# Ensure other users can write to /tmp in case Docker copy (re-)creates the tmp folder as root owner
RUN chmod 777 /tmp

# Update and upgrade the system
#RUN apt-get update
#RUN apt-get install -y apt-utils
#RUN apt-get upgrade -y --no-install-recommends

# Install vim editor
#RUN apt-get install -y vim
