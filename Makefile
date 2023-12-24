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
.PHONY: server client tag help

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
	
	

tag:
	$(DOCKER_TAG) $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest

clean:
	rm -rf $(EXEC_SHELL_SOCK)
	rm -rf $(ROOT_SHELL_SOCK)
	rm -rf  $(SYSTEMD_INIT_PATH)/shell_sock.service
	systemctl daemon-reload

help:
	@echo "Available targets:"
	@echo "  build:     Generate certificates and build the Docker image with the specified version."
	@echo "  tag:       Tag the built image with 'latest'."
	@echo "  help:      /* Build project:            make build"
	@echo "             /* Tag as latest (optional): make tag"
	@echo "             /* Docker network is not created by default. You can create by youself. Check compose file"

# Default target
.DEFAULT_GOAL := help
