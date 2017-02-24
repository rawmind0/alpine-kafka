[![](https://images.microbadger.com/badges/image/rawmind/alpine-kafka.svg)](https://microbadger.com/images/rawmind/alpine-kafka "Get your own image badge on microbadger.com")

alpine-kafka 
==============

This image is the kafka base. It comes from [alpine-jvm8][alpine-jvm8].

## Build

```
docker build -t rawmind/alpine-kafka:<version> .
```

## Versions

- `0.10.2.0-2` [(Dockerfile)](https://github.com/rawmind0/alpine-kafka/blob/0.10.2.0-2/Dockerfile)
- `0.10.2.0-1` [(Dockerfile)](https://github.com/rawmind0/alpine-kafka/blob/0.10.2.0-1/Dockerfile)
- `0.10.0.1-1` [(Dockerfile)](https://github.com/rawmind0/alpine-kafka/blob/0.10.0.1-1/Dockerfile)
- `0.10.0.0-7` [(Dockerfile)](https://github.com/rawmind0/alpine-kafka/blob/0.10.0.0-7/Dockerfile)
- `0.9.0.1-2` [(Dockerfile)](https://github.com/rawmind0/alpine-kafka/blob/0.9.0.1-2/Dockerfile)

## Configuration

This image runs [kafka][kafka] with monit. Kafka is started with user and group "kafka".

Besides, you can customize the configuration in several ways:

### Default Configuration

kafka is installed with the default configuration and some parameters can be overrided with env variables:

- KAFKA_HEAP_OPTS=${JVMFLAGS:-"-Xmx1G -Xms1G"}     				# Kafka memory value
- KAFKA_ADVERTISE_PORT=${KAFKA_ADVERTISE_PORT:-"9092"}			# Port to advertise
- KAFKA_LISTENER=${KAFKA_LISTENER:-"PLAINTEXT://0.0.0.0:${KAFKA_ADVERTISE_PORT}"}	# Listerner string 
- KAFKA_DELETE_TOPICS=${KAFKA_DELETE_TOPICS:-"false"}			# Enable kafka delete topics
- KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-"${SERVICE_HOME}/logs"}		# Log directories.
- KAFKA_LOG_RETENTION_HOURS=${KAFKA_LOG_RETENTION_HOURS:-"168"}	# Log retention hours
- KAFKA_NUM_PARTITIONS=${KAFKA_NUM_PARTITIONS:-"1"}				# Number of partitions
- KAFKA_ZK_HOST=${KAFKA_ZK_HOST:-"127.0.0.1"}					# Zk host
- KAFKA_ZK_PORT=${KAFKA_ZK_PORT:-"2181"}						# Zk port
- KAFKA_EXT_IP=${KAFKA_EXT_IP:-""}								# Advertise external ip or name if value != ""


### Custom Configuration

Kafka is installed under /opt/kafka and make use of /opt/kafka/config/server.properties.

You can edit this files in order customize configuration

You could also include FROM rawmind/alpine-kafka at the top of your Dockerfile, and add your custom config.

### Rancher

If you are running it in rancher, you could run [rancher-kafka][rancher-kafka] as a sidekick to get dynamic configuration.

### k8s

If you are running it in k8s, you could run [k8s-kafka][k8s-kafka] at the same pod to get dynamic configuration.

## Example

See [rancher-example][rancher-example], that run kafka in a rancher system with dynamic configuration.


[alpine-jvm8]: https://github.com/rawmind0/alpine-jvm8/
[kafka]: http://kafka.apache.org/
[rancher-kafka]: https://hub.docker.com/r/rawmind/rancher-kafka/
[k8s-kafka]: https://hub.docker.com/r/rawmind/k8s-kafka/
[rancher-example]: https://github.com/rawmind0/alpine-kafka/tree/master/rancher
[k8s-example]: https://github.com/rawmind0/alpine-kafka/tree/master/k8s
