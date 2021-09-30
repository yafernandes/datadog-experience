cd ../..
gradle war
docker build -t yaalexf/servlet:jetty -f docker/jetty/Dockerfile .
docker push yaalexf/servlet:jetty
cd -