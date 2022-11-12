cd ../..
gradle war
docker buildx build --platform linux/amd64 -t yaalexf/servlet:war --push -f docker/war/Dockerfile .
cd -