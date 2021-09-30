FROM jetty:9.4-jdk8-slim
ADD --chown=jetty:jetty https://dtdg.co/latest-java-tracer /dd-java-agent.jar
COPY app/build/libs/servlet.war /var/lib/jetty/webapps/
ENV JAVA_OPTIONS=-javaagent:/dd-java-agent.jar
