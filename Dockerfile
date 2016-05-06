FROM java:8-jdk-alpine

ENV JMETER_VERSION=2.13


ENV INSTALL_LOCATION=/usr/local

ENV JMETER_BINARY=$INSTALL_LOCATION/apache-jmeter-$JMETER_VERSION/bin/jmeter

# Install JMeter
RUN cd $INSTALL_LOCATION && \
  wget http://www.mirrorservice.org/sites/ftp.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
  tar xzf apache-jmeter-$JMETER_VERSION.tgz && \
  rm -f apache-jmeter-$JMETER_VERSION.tgz


ENV JMETER_PLUGINS_VERSION=1.4.0
RUN cd $INSTALL_LOCATION/apache-jmeter-$JMETER_VERSION && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-Extras-${JMETER_PLUGINS_VERSION}.zip && \
      wget http://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-Standard-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-Extras-${JMETER_PLUGINS_VERSION}.zip && \
      unzip -o JMeterPlugins-ExtrasLibs-${JMETER_PLUGINS_VERSION}.zip

ENV CONSUL_TEMPLATE_VERSION=0.14.0

RUN cd $INSTALL_LOCATION/bin && \
    wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    rm  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip


RUN mkdir -p /etc/consul-template/config.d /etc/consul-template/template.d /tests


ENV CONSUL_WAIT=5s:20s
ENV CONSUL_HOST=consul.service.consul

ADD jmeter-server-start.sh.tmpl /
ADD jmeter-start.sh.tmpl /

ENV START_SCRIPT=jmeter-server-start.sh

ENV RMI_HOST=0.0.0.0


#CMD  consul-template -reap=true -consul $CONSUL_HOST -template "/$START_SCRIPT.tmpl:/$START_SCRIPT:cat /$START_SCRIPT"

CMD  consul-template -reap=true -wait "$CONSUL_WAIT" -consul $CONSUL_HOST -template "/$START_SCRIPT.tmpl:/$START_SCRIPT:killall java; sh /$START_SCRIPT"

# to run/test:
# docker build -t jmeter . &&  docker run -it --rm --net host -e CONSUL_WAIT="0s" -e CONSUL_HOST=x.x.x.x:8500 jmeter
