cd ../..
gradle war
docker build -t yaalexf/servlet:tomcat -f docker/tomcat/Dockerfile .
docker push yaalexf/servlet:tomcat
cd -