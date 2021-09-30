cd ../..
gradle war
docker build -t yaalexf/servlet:wildfly -f docker/wildfly/Dockerfile .
docker push yaalexf/servlet:wildfly
cd -