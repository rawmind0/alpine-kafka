#!/usr/bin/env bash

export SERVICE_CONF=${SERVICE_CONF:-"/opt/kafka/config/server.properties"}

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
    if [ ! -L ${KAFKA_LOG_FILE} ]; then
        rm ${KAFKA_LOG_FILE}
        ln -sf /proc/1/fd/1 ${KAFKA_LOG_FILE}
    fi
}

function serviceCheck {
    log "[ Checking ${SERVICE_NAME} configuration... ]"

    if [ -d "/opt/tools" ]; then
        serviceConf
    else
        serviceDefault
    fi
}

function serviceStart {
    log "[ Starting ${SERVICE_NAME}... ]"
    serviceCheck
    serviceLog
    ${SERVICE_HOME}/bin/kafka-server-start.sh -daemon ${SERVICE_CONF}
}

function serviceStop {
    log "[ Stoping ${SERVICE_NAME}... ]"
    pid=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`

	while [ "x$pid" != "x" ]; do
    	kill -SIGTERM $pid
    	sleep 5 
    	pid=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`
	done
}

function serviceRestart {
    log "[ Restarting ${SERVICE_NAME}... ]"
    serviceStop
    serviceStart
    /opt/monit/bin/monit reload
}

case "$1" in
        "start")
            serviceStart
        ;;
        "stop")
            serviceStop
        ;;
        "restart")
            serviceRestart
        ;;
        *) echo "Usage: $0 restart|start|stop"
        ;;

esac
