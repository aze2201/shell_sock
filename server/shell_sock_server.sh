#!/bin/bash

## Author: Fariz Muradov

# read config file if exist
[ -f /etc/shell_sock/server/config/*.conf ] &&
     (  
         echo "Loading configuration"
         set -a
         source /etc/shell_sock/server/config/*.conf
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
       echo "To share accept terminal PTY requires certificates wich is signed by any CA"
       echo "Generate private key: root@shell_sock:~\# openssl genrsa -out certs/server.key 4096"
       echo "Generate CSR key:     root@shell_sock:~\# openssl req -new -key certs/server.key -out certs/server.csr"
       echo "Send CSR file to CA and obtain signed PEM or CRT file and store certs folder (x509)"
       echo "Get CA public key chain"
       echo ""
       echo "  {-k|--key     }  private key   -- Set prvate key     or   root@shell_sock:~# export KEY="
       echo "  {-c|--cert    }  public key    -- Set public key     or   root@shell_sock:~# export CERT="
       echo "  {-C|--ca-cert }  CA file       -- Set CA public key  or   root@shell_sock:~# export CA_CERT="
       echo "  {-p|--port    }  PORT          -- Set listen port    or   root@shell_sock:~# export PORT="
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
                   [ $# = 0 ] && error "No tcp listen port specified"
                   export PORT="$1"
                   shift;;
               (-h|--help)
                   help;;
               (*) help;;
           esac
		
done

$([ ! -z $KEY ] && [ ! -z $CERT ] && [ ! -z $CA_CERT ] && [ ! -z $PORT ]) && no_args=1 || no_args=0
[[ "$no_args" -ne "1" ]] && { echo "";echo "ERROR: Some of arguments are not specified !! "; help; exit 1; }

echo "SERVER START 0.0.0.0:$PORT"
socat openssl-listen:$PORT,fork,cert=$CERT,key=$KEY,cafile=$CA_CERT,verify=4 'system:
{
    # read inial message as port
    read port
    export port
    # make it raw
    port=$(echo ${port}| tr "\r" " "| sed "s/ //" )
    
    # open session
    while true;do
      # check port are open
      lsof -i :$port > /dev/null
      if [ $? -eq 0 ]; then
         # if client open port then forward to that
         socat - TCP4:127.0.0.1:$port
       fi
      # wait and keep connection
      sleep 2s
    done
}'
