#!/bin/sh
#
# File: service.sh
# Desc: UnblockNeteaseMusic service control script
# Date: 2021-04-10

# sleep seconds after recieving term signal
if [ -z "$PRESTOP_SECONDS" ]; then
    PRESTOP_SECONDS=5
fi

# flag of backing down with docker stop signal
# default false mean unexpected crash
DOCKER_STOP=false

# get config from environment variables
get_config(){
    _opt=''
    [ "x$UNM_FORCE_BEST" = 'xon' ] && _opt="$_opt -b"
    [ "x$UNM_REPLACE_URL" = 'xon' ] && _opt="$_opt -e"
    if [ ! -z "$UNM_SERVER_CERT" ]; then
        if [ -f "$UNM_SERVER_CERT" ]; then
            _opt="$_opt -c $UNM_SERVER_CERT"
        else
            echo "server cert file is not exists: $UNM_SERVER_CERT"
            exit 1
        fi
    fi
    if [ ! -z "$UNM_SERVER_KEY" ]; then
        if [ -f "$UNM_SERVER_KEY" ]; then
            _opt="$_opt -k $UNM_SERVER_KEY"
        else
            echo 'server cert key file is not exists'
            exit 1
        fi
    fi
    if [ ! -z "$UNM_LOG_FILE" ]; then
        mkdir -p `dirname $UNM_LOG_FILE`
        if [ $? -ne 0 ]; then
            echo 'cannot create parent directory of log file'
            exit 1
        else
            _opt="$_opt -l $UNM_LOG_FILE"
        fi
    fi
    if [ ! -z "$UNM_SERVER_SOURCE" ]; then
        if ! echo "$UNM_SERVER_SOURCE" | grep -wqE 'kuwo|migu|kugou'; then
            echo "invalid server source: $UNM_SERVER_SOURCE"
            exit 1
        else
            _opt="$_opt -o $UNM_SERVER_SOURCE"
        fi
    fi
    if [ ! -z "$UNM_RUNNING_MODE" ]; then
        if echo "$UNM_RUNNING_MODE" | grep -qwE '[0-9]'; then
            _opt="$_opt -m $UNM_RUNNING_MODE"
        else
            echo "invalid running mode: $UNM_RUNNING_MODE"
            exit 1
        fi
    fi

    if [ ! -z "$UNM_SERVER_PORT" ]; then
        if echo "$UNM_SERVER_PORT" | grep -qwE '[0-9]+'; then
            _opt="$_opt -p $UNM_SERVER_PORT"
        else
            echo "invalid port: $UNM_SERVER_PORT"
            exit 1
        fi
    fi
    if [ ! -z "$UNM_SERVER_TLS_PORT" ]; then
        if echo "$UNM_SERVER_TLS_PORT" | grep -qwE '[0-9]+'; then
            _opt="$_opt -sp $UNM_SERVER_TLS_PORT"
        else
            echo "invalid port: $UNM_SERVER_TLS_PORT"
            exit 1
        fi
    fi
    if [ ! -z "$UNM_SEARCH_TIME" ]; then
        if echo "$UNM_SEARCH_TIME" | grep -qwE '[0-9]'; then
            _opt="$_opt -sl $UNM_SEARCH_TIME"
        else
            echo "invalid search time: $UNM_SEARCH_TIME"
            exit 1
        fi
    fi
    export UNM_OPTION="$_opt"
}

# check pid valid
check_service_by_pid(){
    if [ ! -z "$UNM_PID" ]; then
        if ! ps axu | awk '{print $1}' | grep "^${UNM_PID}\$" > /dev/null; then
            echo "UnblockNeteaseMusic is not running"
            return 1
        fi
    fi
    return 0
}

# start service
start_service(){
    echo /root/app/UnblockNeteaseMusic $UNM_OPTION
    /root/app/UnblockNeteaseMusic $UNM_OPTION &
    export UNM_PID="$!"
}


# stop service
stop_service(){
    _quick="$1"
    # check for quick stoping or normal stoping
    if [ "x$_quick" != "xquick" ] && [ "x$ENV" != "xTEST" ]; then
        echo "prepare stop service, sleep $PRESTOP_SECONDS..."
        for i in `seq 1 $PRESTOP_SECONDS`; do
            sleep 1
            echo "prepare stop service for $i seconds."
        done
    fi
    # check UnblockNeteaseMusic is alive then stop it
    if [ ! -z "$UNM_PID" ] && \
        ps axu | awk '{print $1}' | grep "^${UNM_PID}\$" > /dev/null; then
        echo "stoping UnblockNeteaseMusic: kill -s TERM $UNM_PID"
        kill -s TERM $UNM_PID
        wait $!
    fi
    echo "all service stop."
}


# trap script
trap_term(){
    echo 'get terminal signal, stop service...'
    # just stop nginx and python gunicorn.
    stop_service
    # set flag for docker stop
    DOCKER_STOP=true
}

main(){
    # trap 15 signal
    trap 'trap_term' SIGTERM

    # start service
    get_config
    start_service

    # hold docker
    while ! $DOCKER_STOP ; do
        if ! check_service_by_pid; then
            stop_service quick
            exit 0
        fi
        sleep 2
    done

    # wait child
    wait
    echo "init process end"
}

main


