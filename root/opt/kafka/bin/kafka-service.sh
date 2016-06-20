#!/usr/bin/env bash

export SERVICE_CONF=${SERVICE_CONF:-"/opt/kafka/config/server.properties"}

export KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}
export KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
export KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:${KAFKA_ADVERTISE_PORT}"}
export KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-"${SERVICE_HOME}/logs"}
export KAFKA_LOG_FILE=${KAFKA_LOG_FILE:-"${KAFKA_LOG_DIRS}/kafkaServer.out"}
export KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
export KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
export KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}
export KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}

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
