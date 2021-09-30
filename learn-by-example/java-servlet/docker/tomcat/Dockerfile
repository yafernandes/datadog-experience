FROM tomcat:9-jre8-alpine
ADD https://dtdg.co/latest-java-tracer /dd-java-agent.jar
COPY app/build/libs/servlet.war /usr/local/tomcat/webapps/
ENV CATALINA_OPTS=-javaagent:/dd-java-agent.jar
ENV DD_JMXFETCH_TOMCAT_ENABLED=true
