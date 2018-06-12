#!/usr/bin/env bash

SERVICE_LOG_DIR=${KAFKA_LOG_DIRS:-${SERVICE_HOME}"/logs"}
SERVICE_LOG_FILE=${SERVICE_LOG_FILE:-${SERVICE_LOG_DIR}"/server.log"}

function log {
        echo `date` $ME - $@
}

function serviceDefault {
    log "[ Applying default ${SERVICE_NAME} configuration... ]"
    ${SERVICE_HOME}/bin/server.properties.sh
}

function serviceConf {
    log "[ Applying dinamic ${SERVICE_NAME} configuration... ]"
    while [ ! -f ${SERVICE_CONF} ]; do
        log " Waiting for ${SERVICE_NAME} configuration..."
        sleep 3 
    done
}

function serviceLog {
    log "[ Redirecting ${SERVICE_NAME} log to stdout... ]"
    if [ ! -L ${SERVICE_LOG_FILE} ]; then
        rm ${SERVICE_LOG_FILE}
        ln -sf /proc/1/fd/1 ${SERVICE_LOG_FILE}
    fi
}

function serviceCheck {
    log "[ Checking ${SERVICE_NAME} configuration... ]"

    if [ -d "${SERVICE_VOLUME}" ]; then
        serviceConf
    else
        serviceDefault
    fi
}

function serviceStart {
    log "[ Starting ${SERVICE_NAME}... ]"
    serviceCheck
    serviceLog
    if [ ! -f ${SERVICE_HOME}/${SERVICE_NAME}.pid ]; then
        nohup ${SERVICE_HOME}/bin/kafka-server-start.sh ${SERVICE_CONF} 2>&1 >> ${SERVICE_LOG_FILE} 2>&1 &
        echo $! > ${SERVICE_HOME}/${SERVICE_NAME}.pid
    else 
        log "[ ${SERVICE_NAME} is already running]"
        serviceRestart
    fi
}

function serviceStop {
    log "[ Stoping ${SERVICE_NAME}... ]"
    if [ -f ${SERVICE_HOME}/${SERVICE_NAME}.pid ]; then
        pid=`cat ${SERVICE_HOME}/${SERVICE_NAME}.pid`
        kill -SIGTERM $pid

    	until [ `ps --pid $pid 2> /dev/null | grep -c $pid 2> /dev/null` -eq '0' ]
        do
            log "[ Waiting to stop ${SERVICE_NAME} process... ]"
            sleep 5
        done

        rm ${SERVICE_HOME}/${SERVICE_NAME}.pid
    fi
}

function serviceRestart {
    log "[ Restarting ${SERVICE_NAME}... ]"
    serviceStop
    serviceStart
    /opt/monit/bin/monit reload
}

case "$1" in
        "start")
            serviceStart &>> /proc/1/fd/1
        ;;
        "stop")
            serviceStop &>> /proc/1/fd/1
        ;;
        "restart")
            serviceRestart &>> /proc/1/fd/1
        ;;
        *) 
            echo "Usage: $0 restart|start|stop"
            exit 1
        ;;

esac

exit 0
