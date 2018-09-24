FROM rawmind/alpine-jvm8:1.8.181-1
MAINTAINER Raul Sanchez <rawmind@gmail.com>

# Set environment
ENV SERVICE_HOME=/opt/kafka \
    SERVICE_NAME=kafka \
    SCALA_VERSION=2.12 \
    SERVICE_VERSION=1.1.0 \
    SERVICE_USER=kafka \
    SERVICE_UID=10003 \
    SERVICE_GROUP=kafka \
    SERVICE_GID=10003 \
    SERVICE_VOLUME=/opt/tools \
    SERVICE_URL=http://apache.mirrors.spacedump.net/kafka 
ENV SERVICE_RELEASE=kafka_"$SCALA_VERSION"-"$SERVICE_VERSION" \
    SERVICE_CONF=${SERVICE_HOME}/config/server.properties \
    PATH=$PATH:${SERVICE_HOME}/bin

# Install and configure kafka
RUN curl -sS -k ${SERVICE_URL}/${SERVICE_VERSION}/${SERVICE_RELEASE}.tgz | gunzip -c - | tar -xf - -C /opt \
  && mv /opt/${SERVICE_RELEASE} ${SERVICE_HOME} \
  && rm -rf ${SERVICE_HOME}/bin/windows \
  && rm ${SERVICE_CONF} \
  && mkdir ${SERVICE_HOME}/data ${SERVICE_HOME}/logs \
  && addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} \
  && adduser -g "${SERVICE_NAME} user" -D -h ${SERVICE_HOME} -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} 

ADD root /
RUN chmod +x ${SERVICE_HOME}/bin/*.sh \
  && chown -R ${SERVICE_USER}:${SERVICE_GROUP} ${SERVICE_HOME} /opt/monit


USER $SERVICE_USER
WORKDIR $SERVICE_HOME

EXPOSE 9092
