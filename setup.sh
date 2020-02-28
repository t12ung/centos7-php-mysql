#!/usr/bin/env bash
# This script requires perl command for multiline regex.

# Color vars
_RST_='\033[0m'  #reset
_BLD='\033[1m'   #bold
_UND='\033[4m' #underline

# Normal Colors
Black='\033[38;5;0m'
Red='\033[38;5;1m'
Green='\033[38;5;2m'
Yellow='\033[38;5;3m'
Blue='\033[38;5;4m'
Magenta='\033[38;5;5m'
Cyan='\033[38;5;6m'
White='\033[38;5;7m'

# High Intensty
IBlack='\033[38;5;8m'
IRed='\033[38;5;9m'
IGreen='\033[38;5;10m'
IYellow='\033[38;5;11m'
IBlue='\033[38;5;12m'
IMagenta='\033[38;5;13m'
ICyan='\033[38;5;14m'
IWhite='\033[38;5;15m'


which perl > /dev/null
if [[ "$?" -ne 0 ]]; then
    echo -e "${_BLD}${Red}Error${_RST_}: Setup cannot continue - '${Yellow}perl${_RST_}' command not found!"
    echo "Install perl and try again."
    exit $?
fi

SRC_FILE=${0##*/}
if [[ "$SRC_FILE" == "setup.sh" ]]; then
  SRC_FILE='./'$SRC_FILE
fi
YML_FILE=./docker-compose.yml
YML_BAK=./docker-compose_orig.yml
ENV_FILE=./.env
HTTPD_PORT=''
MYSQL_PORT=3306
DOCKER_CONTAINER=''

SYS_OS=$(uname -a)
NIX_HOSTS=/etc/hosts
MS_HOSTS=''
WINDOWS_SH=''
WINPTY=''
WIN_ERR=''
SUDOER=''

if [[ "$SYS_OS" =~ [Mm]icrosoft ]] || [[ "$SYS_OS" =~ MINGW64_NT ]]; then
  if [[ "$SYS_OS" =~ [Mm]icrosoft ]]; then
    WINDOWS_SH='WSL'
  fi
  if [[ "$SYS_OS" =~ MINGW64_NT ]]; then
    WINDOWS_SH='GitBash'
    WINPTY='winpty '
  fi
  WINDIR=$(echo :${PATH}:|grep -oP '(?<=:)\/[^:]*?System32'|grep -i 'windows'|head -1)
  if [[ "$WINDIR" != "" ]]; then
    MS_HOSTS=${WINDIR}/drivers/etc/hosts
  else
    # Can't find WINDIR from PATH env variable, then try default location
    if [[ -d "/c/Windows/System32" ]]; then
      MS_HOSTS="/c/Windows/System32/drivers/etc/hosts"
    else
      WIN_ERR=true
    fi
  fi
fi

# Check for SUDO to update NIX_HOSTS
# GitBash doesn't need any other requirements to update NIX_HOSTS
if [[ $(id -un) == 'root' ]] || [[ "$WINDOWS_SH" == "GitBash" ]]; then
  touch $NIX_HOSTS > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    SUDOER=true
  fi
fi

# GitBash and WSL require 'Run as Admin' to update windows hosts file
if [[ "$WINDOWS_SH" != "" ]]; then
  if [[ "${WIN_ERR,,}" != "true" ]]; then
    touch $MS_HOSTS > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      WIN_ERR=true
    fi
  fi
fi

if [[ "${WIN_ERR,,}" == "true" ]] || [[ "${SUDOER,,}" != "true" ]]; then
  echo -e "\n${_BLD}${Red}No permissions${_RST_} to automatically update system ${_BLD}${Blue}hosts${_RST_} file(s)."

  if [[ "${WIN_ERR,,}" == "true" ]]; then
    # WSL requires 'sudo', but cannot find PATH containing Windows Directory (Root does not normally have this set)
    WSL_ERROR="Open Terminal as ${_BLD}${Yellow}Administrator${_RST_} and run '${_BLD}sudo ${SRC_FILE}${_RST_}'"
  else
    WSL_ERROR="Run '${_BLD}sudo ${SRC_FILE}${_RST_}'"
  fi
  if [[ "$WINDOWS_SH" == "GitBash" ]]; then
      echo -e "Open Git Bash as ${_BLD}Administrator${_RST_} to allow permissions and then run ${_BLD}${SRC_FILE}${_RST_}"
  else
      echo -e $WSL_ERROR
  fi

  answer=''
  while [[ -z "$answer" ]]
  do
    echo -en "\nDo you still want to continue and manually update the hosts file(s) yourself later?"
    read -rp ' [y|n]: ' input

    case $input in
      [Yy][Ee][Ss]|[Yy])
        echo ""
        answer=yes
      ;;
      [Nn][Oo]|[Nn])
        answer=no
        exit 1
      ;;
    esac
  done
fi

# Set working directory is the location of this file to ensure relative file paths are correct
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
cd $DIR


echo -e "The Nginx Web Proxy enables you to run ${_UND}mulitple webservers${_RST_} without conflicts, even if using the same port number.\n"
echo -e "The MySQL service is ${_BLD}NOT${_RST_} proxied via Nginx service but accessed directly on localhost or 127.0.0.1 - \
The service will be accessible via the internal docker network on the standard port 3306. \
Connection to the database service outside of the docker network is on the external port. \
If you are running multiple database services, you need to choose an external port that is not already used on your local machine.\n"


function proxy(){
    # backup original
    if [[ ! -f ./docker-compose_orig.yml ]]; then
        cp $YML_FILE $YML_BAK
    fi

    if [[ -f $YML_BAK ]]; then
        SRC_YML_FILE=./docker-compose_orig.yml
    else
        SRC_YML_FILE=$YML_FILE
    fi

    if [[ "$1" -ne 1 ]]; then
        perl -0777 \
            -pe 's/\s+networks.*?name: nginx-proxy\s+/\n/gs;' \
            -pe 's/(webserver.*?)expose(.*)80/$1ports$2\80:80/gs;' \
            $SRC_YML_FILE > $YML_FILE
    else
        if [[ -f $YML_BAK ]] && [[ $YML_FILE -nt $YML_BAK ]]; then
            cp $YML_BAK $YML_FILE
        fi
    fi
}

function ports(){
    local PATTERN

    if [[ "$1" == "apache" ]]; then
        if [[ "${NGINX_PROXY,,}" == "true" ]]; then
            PATTERN="s/(webserver.*?expose.*?)80/\${1}$2/gs"
        else
            PATTERN="s/(webserver.*?ports.*?)80:80/\${1}$2:$2/gs"
        fi
    elif [[ "$1" == "mysql" ]]; then
        PATTERN="s/(mysql.*?ports.*?)\d+:/\${1}$2:/gs"
    fi

    perl -0777 -i -pe $PATTERN $YML_FILE
}

function env_var(){
    local ENV_VAR VALUE

    if [[ "$1" == "apache" ]]; then
        ENV_VAR='APACHE_LOGS'
    elif [[ "$1" == "mysql" ]]; then
        ENV_VAR='MYSQL_LOGS'
    else
        ENV_VAR="$1"
    fi

    if [[ "$2" == "1" ]] ;then
        VALUE=true
    elif [[ "$2" == "0" ]] ;then
        VALUE=false
    else
        VALUE="$2"
    fi

    perl -0777 -i -pe "s/($ENV_VAR=).*/\1$VALUE/g" $ENV_FILE
}


# Begin the configuration
answer=''
while [[ -z "$answer" ]]
do
    echo -en "Do you want to use ${_BLD}${Blue}Nginx${_RST_} Web Proxy?"
    read -rp ' [y|n]: ' input

    case $input in
        [Yy][Ee][Ss]|[Yy])
            NGINX_PROXY=true
            proxy 1
            answer=yes
        ;;
        [Nn][Oo]|[Nn])
            proxy 0
            answer=no
        ;;
    esac
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Do you want to enable ${_BLD}${Blue}Apache${_RST_} Logs? (Default=no)"
    read -rp ' [y|n]: ' input

    case $input in
        [Yy][Ee][Ss]|[Yy])
            env_var "apache" 1
            answer=yes
        ;;
        [Nn][Oo]|[Nn])
            env_var "apache" 0
            answer=no
        ;;
    esac
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Do you want to enable ${_BLD}${Blue}MySQL${_RST_} Logs? (Default=no)"
    read -rp ' [y|n]: ' input

    case $input in
        [Yy][Ee][Ss]|[Yy])
            env_var "mysql" 1
            answer=yes
        ;;
        [Nn][Oo]|[Nn])
            env_var "mysql" 0
            answer=no
        ;;
    esac
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Would you like to change the default port(80) for the ${_BLD}${Blue}httpd${_RST_} service?"
    read -rp ' [port#|n]: ' input

    case $input in
        [Nn][Oo]|[Nn])
            answer=no
        ;;
        *)
            if [[ "$input" -gt 0 ]] && [[ "$input" -le 65535 ]]; then
                ports "apache" $input
                HTTPD_PORT=":$input"
                answer=yes
            fi
        ;;
    esac
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Would you like to change the default ${_BLD}${Green}external${_RST_} port(3306) for the ${_BLD}${Blue}mysqld${_RST_} service?"
    read -rp ' [port#|n]: ' input

    case $input in
        [Nn][Oo]|[Nn])
            answer=no
        ;;
        *)
            if [[ "$input" -gt 0 ]] && [[ "$input" -le 65535 ]]; then
                ports "mysql" $input
                MYSQL_PORT=$input
                answer=yes
            fi
        ;;
    esac
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Choose a name prefix for your Webserver/MySQL ${_BLD}${Blue}docker containers${_RST_}"
    read -rp ': ' input

    if [[ -n "$input" ]]; then
        DOCKER_CONTAINER="$input"
        env_var "CONTAINER_PREFIX" $DOCKER_CONTAINER
        answer=yes
    fi
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "Do you want to use ${_BLD}${DOCKER_CONTAINER}${_RST_} as ${_BLD}${Blue}host name${_RST_} or choose a different name?"
    read -rp ' [y|<host_name>]: ' input

    case $input in
        [Yy][Ee][Ss]|[Yy])
            VHOST_NAME=$DOCKER_CONTAINER
        ;;
        *)
            VHOST_NAME="$input"
        ;;
    esac

    if [[ -n "$input" ]]; then
        env_var "VHOST" $VHOST_NAME
        answer=yes
    fi
done

answer=''
while [[ -z "$answer" ]]
do
    echo -en "What is the ${_BLD}${Blue}domain${_RST_} for your Webserver?"
    read -rp ': ' input

    if [[ -n "$input" ]]; then
        VDOMAIN_NAME="$input"
        env_var "VDOMAIN" $VDOMAIN_NAME
        answer=yes
    fi
done


echo -e "\nYour Docker Compose file is now configured. After you have built your containers...\n\n\
You can access your website at:\n\
http://${VHOST_NAME}.${VDOMAIN_NAME}${HTTPD_PORT}/\n\n\
Configure your website to connect to the database on:\n\
Host: ${DOCKER_CONTAINER}-5.7.x-mysql\n\
Port: 3306\n\
Username/Password can be found in the .env file\n\n\
Configure your MySQL client to connect to the database on:\n\
Host: localhost or 127.0.0.1\n\
Port: ${MYSQL_PORT}"

if [[ -f "$NIX_HOSTS" ]] || [[ -f "$MS_HOSTS" ]]; then
  echo -e "\nhosts file(s) found:"
  if [[ -f "$MS_HOSTS" ]]; then
    echo -e "${_BLD}${Blue}Windows${_RST_} : $MS_HOSTS"
    if [[ -f "$NIX_HOSTS" ]]; then
      if [[ "$SYS_OS" =~ MINGW64_NT ]]; then
        echo -en "${_BLD}${Blue}GitBash${_RST_}"
      elif [[ "$SYS_OS" =~ [Mm]icrosoft ]]; then
        echo -en "${_BLD}${Blue}WSL${_RST_}    "
      fi
        echo -e " : $NIX_HOSTS"
    fi
  elif [[ -f "$NIX_HOSTS" ]]; then
    echo "$NIX_HOSTS"
  fi
fi

if [[ "${SUDOER,,}" == "true" ]] && [[ -f "$NIX_HOSTS" ]]; then
  answer=''
  while [[ -z "$answer" ]]
  do
    echo -en "\nAdd \"${_BLD}${Green}127.0.0.1    ${VHOST_NAME}.${VDOMAIN_NAME}\"${_RST_} to $NIX_HOSTS?"
    read -rp ' [y|n]: ' input

    case $input in
      [Yy][Ee][Ss]|[Yy])
        echo -e "\n127.0.0.1    ${VHOST_NAME}.${VDOMAIN_NAME}" >> $NIX_HOSTS
        answer=yes
      ;;
      [Nn][Oo]|[Nn])
        answer=no
      ;;
    esac
  done
fi
if [[ "${WIN_ERR,,}" != "true" ]] && [[ -f "$MS_HOSTS" ]]; then
  answer=''
  while [[ -z "$answer" ]]
  do
    echo -en "\nAdd \"${_BLD}${Green}127.0.0.1    ${VHOST_NAME}.${VDOMAIN_NAME}\"${_RST_} to $MS_HOSTS?"
    read -rp ' [y|n]: ' input

    case $input in
      [Yy][Ee][Ss]|[Yy])
        echo -e "\n127.0.0.1    ${VHOST_NAME}.${VDOMAIN_NAME}" >> $MS_HOSTS
        answer=yes
      ;;
      [Nn][Oo]|[Nn])
        answer=no
      ;;
    esac
  done
fi

if [[ "${SUDOER,,}" != "true" ]] || [[ "${WIN_ERR,,}" == "true" ]]; then
  echo -e "\n${_BLD}${Yellow}!! Remember${_RST_} to add \"${_BLD}${Green}127.0.0.1    ${VHOST_NAME}.${VDOMAIN_NAME}\"${_RST_} to all hosts file(s)!"
  if [[ "$MS_HOSTS" == '' ]]; then
    echo -e "\nCould not determine location of Windows hosts file.
This default location can be found by running the following command in a Windows Command Prompt:
cd %WINDIR%\\\System32\\\drivers\\\etc"
  fi
fi

if [[ "${NGINX_PROXY,,}" == "true" ]]; then
echo -e "\nAs you have chosen to use the Nginx Web Proxy, you should start that service first:\n\
${_BLD}${Cyan}\$${_RST_}${_BLD} docker network create nginx-proxy${_RST_} (create the network)
${_BLD}${Cyan}\$${_RST_}${_BLD} docker-compose up${_RST_} (start service from Nginx container directory)"
fi

echo -e "\nRun and build your Docker Containers with:\n\
docker-compose up --build\n\n\
Confirm access to your website works (you should see a phpinfo page).\n\n\
To open a shell to your docker containers, run:\n\
web : ${WINPTY}docker exec -it ${DOCKER_CONTAINER}-7.3.x-webserver bash\n\
db  : ${WINPTY}docker exec -it ${DOCKER_CONTAINER}-5.7.x-mysql bash\n\n\
After confirming your servers are working, copy your website code folder into the ${_BLD}www${_RST_} directory \
(or checkout your code as a directory), and update ${_BLD}${Blue}DOCUMENT_ROOT${_RST_} in the .env file. \
You need to ${_BLD}restart${_RST_} the webserver container for the DOCUMENT_ROOT change to take effect."
