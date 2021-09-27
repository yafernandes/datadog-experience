FROM openjdk:11-slim
ADD app/build/distributions/app.tar /
WORKDIR /app
ADD https://dtdg.co/latest-java-tracer /dd-java-agent.jar
ENV JAVA_OPTS -javaagent:/dd-java-agent.jar
CMD [ "bin/app" ]
