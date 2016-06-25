#!/usr/bin/env bash

KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}
KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}
KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:"${KAFKA_ADVERTISE_PORT}}
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-${SERVICE_HOME}"/logs"}
KAFKA_LOG_FILE=${KAFKA_LOG_FILE:-${KAFKA_LOG_DIRS}"/kafkaServer.out"}
KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}
KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}
KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}
KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}

if [ "$KAFKA_EXT_IP" == "" ]; then
 	KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-${KAFKA_LISTENER}}
else
	KAFKA_ADVERTISE_LISTENER=${KAFKA_ADVERTISE_LISTENER:-"PLAINTEXT://${KAFKA_EXT_IP}:"${KAFKA_ADVERTISE_PORT}}
fi

cat << EOF > ${SERVICE_CONF}
############################# Server Basics #############################
broker.id=0
############################# Socket Server Settings #############################
listeners=${KAFKA_LISTENER}
advertised.listeners=${KAFKA_ADVERTISE_LISTENER}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
############################# Log Basics #############################
log.dirs=${KAFKA_LOG_DIRS}
num.partitions=${KAFKA_NUM_PARTITIONS}
num.recovery.threads.per.data.dir=1
############################# Log Flush Policy #############################
#log.flush.interval.messages=10000
#log.flush.interval.ms=1000
############################# Log Retention Policy #############################
log.retention.hours=${KAFKA_LOG_RETENTION_HOURS}
#log.retention.bytes=1073741824
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
log.cleaner.enable=true
############################# Connect Policy #############################
zookeeper.connect=${KAFKA_ZK_HOST}:2181
zookeeper.connection.timeout.ms=6000
EOF

