#!/bin/sh
#
# File: env_test.sh
# Desc: 
# Date: 2021-04-10


export UNM_FORCE_BEST=on
export UNM_REPLACE_URL=on
export UNM_SERVER_CERT=/root/app/server.crt
export UNM_SERVER_KEY=/root/app/server.key
export UNM_LOG_FILE=/root/app/log/1.log
export UNM_SERVER_SOURCE=kugou
export UNM_RUNNING_MODE=2
export UNM_SERVER_PORT=8000
export UNM_SERVER_TLS_PORT=8443
export UNM_SEARCH_TIME=2

sh -x /root/app/service.sh