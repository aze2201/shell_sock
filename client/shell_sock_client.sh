#!/bin/bash


# read config file if exist
[ -f /etc/shell_sock/client/config/*.conf ] &&
     (  
         echo "Loading configuration"
         set -a
         source /etc/shell_sock/client/config/*.conf
         set +a
         echo "Configurations are loaded"
     )



usage()
{
    exec 1>2   # Send standard output to standard error
    help
    exit 1
}

error()
{
    echo "$arg0: $*" >&2
    exit 1
}


help()
{
    echo
    echo "To share terminal to server requires certificates wich is signed by any CA"
    echo "Generate private key: root@shell_sock:~\# openssl genrsa -out certs/server.key 4096"
    echo "Generate CSR key:     root@shell_sock:~\# openssl req -new -key certs/server.key -out certs/server.csr"
    echo "Send CSR file to CA and obtain signed PEM or CRT file and store certs folder (x509)"
    echo "Get CA public key chain"
    echo ""
    echo "  {-k|--key        }  private key  -- Set prvate key       or   root@shell_sock:~# export KEY="
    echo "  {-c|--cert       }  public key   -- Set public key       or   root@shell_sock:~# export CERT="
    echo "  {-C|--ca-cert    }  CA file      -- Set CA public key    or   root@shell_sock:~# export CA_CERT="
    echo "  {-p|--port       }  PORT         -- Set listen port      or   root@shell_sock:~# export PORT="
    echo "  {-s|--server     }  SERVER       -- Set server ip|domain or   root@shell_sock:~# export SERVER="
    echo "  {-l|--local-port }  LPORT        -- Set port in remote   or   root@shell_sock:~# export LPORT="
    echo ""               
    exit 0
}

# input arguments
no_args="0"
while test $# -gt 0
     do
          case "$1" in
              (-k|--key)
                  shift
                  [ $# = 0 ] && error "No private key specified"
                  export KEY="$1";
                  shift;;
              (-c|--cert)
                  shift
                  [ $# = 0 ] && error "No public key specified"
                  export CERT="$1"
                  shift;;
              (-C|--ca-cert)
                  shift
                  [ $# = 0 ] && error "No ca public key specified"
                  export CA_CERT="$1"
                  shift;;
              (-p|--port)
                  shift
                  [ $# = 0 ] && error "No tcp server port specified"
                  export PORT="$1"
                  shift;;
              (-s|--server)
                  shift
                  [ $# = 0 ] && error "No tcp server specified"
                  export SERVER="$1"
                  shift;;
              (-l|--local-port)
                  shift
                  [ $# = 0 ] && error "No reverse local port"
                  export LPORT="$1"
                  shift;;
              (-h|--help)
                  help;;
              (*) help;;
          esac

done

$([ ! -z $KEY ] && [ ! -z $CERT ] && [ ! -z $CA_CERT ] && [ ! -z $PORT ] && [ ! -z $SERVER ] && [ ! -z $LPORT ]) && no_args=1 || no_args=0
[[ "$no_args" -ne "1" ]] && { echo "";echo "ERROR: Some of arguments are not specified !! "; help; exit 1; }


echo "..Startging to connect to: $SERVER:$PORT to accept connection 127.0.0.1:$LPORT"
while true ; do 
  socat OPENSSL:$SERVER:$PORT,cafile=$CA_CERT,key=$KEY,cert=$CERT,verify=4 system:'echo $LPORT; TERM=xterm-256color /bin/bash',pty,stderr,setsid,sigint,sane
  sleep 5s
  echo "Will attempt again. Nobody connected to me"
done
