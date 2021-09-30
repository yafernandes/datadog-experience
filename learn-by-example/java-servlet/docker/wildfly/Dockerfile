FROM jboss/wildfly:24.0.0.Final
ADD --chown=jboss:jboss https://dtdg.co/latest-java-tracer /dd-java-agent.jar
COPY app/build/libs/servlet.war /opt/jboss/wildfly/standalone/deployments/
ENV JAVA_OPTS=-javaagent:/dd-java-agent.jar
