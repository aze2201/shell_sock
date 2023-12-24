# Load variable definitions from variables.env
#include variables.env






# systemd
SYSTEMD_INIT_PATH := /etc/systemd/system

# current
CURR_SHELL_SOCK := `pwd`
ROOT_SHELL_SOCK := /etc/shell_sock
SERV_SHELL_SOCK := $(ROOT_SHELL_SOCK)/server
CLNT_SHELL_SOCK := $(ROOT_SHELL_SOCK)/client

# Target server
SERV_CONF_SHELL_SOCK := $(SERV_SHELL_SOCK)/config
SERV_CERT_SHELL_SOCK := $(SERV_SHELL_SOCK)/certs

# Target client
CLNT_CONF_SHELL_SOCK := $(CLNT_SHELL_SOCK)/config
CLNT_CERT_SHELL_SOCK := $(CLNT_SHELL_SOCK)/certs



# Targets
.PHONY: server client help

server:
	# Install requirement tool.
	if ! command -v socat; then    \
		if command -v apt; then    \
			apt-get install socat; \
		else                       \
			yum install socat;     \
		fi;                        \
	fi
	
	# configure folders
	[ ! -d $(ROOT_SHELL_SOCK) ] &&           \
	  (                                      \
	     mkdir    $(ROOT_SHELL_SOCK)      && \
	     mkdir -p $(SERV_CONF_SHELL_SOCK) && \
		 mkdir -p $(SERV_CERT_SHELL_SOCK)    \
	   )
	   
	# copy to /etc/ folder
	cp -r $(CURR_SHELL_SOCK)/server/config/server.conf $(SERV_CONF_SHELL_SOCK)/
	cp -r $(CURR_SHELL_SOCK)/server/shell_sock_server.sh $(ROOT_SHELL_SOCK)/
	cp -r $(CURR_SHELL_SOCK)/server/config/shell_sock.service $(SYSTEMD_INIT_PATH)/shell_sock.service
	chmod +x $(ROOT_SHELL_SOCK)/shell_sock_server.sh
	systemctl daemon-reload
	systemctl enable shell_sock.service

client:
	mkdir /etc/shell_sock
	
	

clean:
	rm -rf $(EXEC_SHELL_SOCK)
	rm -rf $(ROOT_SHELL_SOCK)
	rm -rf  $(SYSTEMD_INIT_PATH)/shell_sock.service
	systemctl daemon-reload

help:
	@echo "Available targets:"
	@echo "  server:       Installs server software"
	@echo "  client:       Install agent on IoT device"
	@echo "  help:      /* Build server:            make server"
	@echo "  help:      /* Build client:            make client"
	@echo "             /* 1. generate certificates and sign with CA"
	@echo "             /* 2. Copy key, public PEM, CA PEM chain to /etc/shell_sock_server/server|client/certs folder"
	@echo "             /* 3. Configure keys absolute path and other parameters in /etc/shell_sock/server/config/server.conf|client.conf"
	@echo "             /* 4. Start software systemtl start shell_sock_server.service or systemtl start shell_sock_client.service "

# Default target
.DEFAULT_GOAL := help
