docker network create artifactory

docker run --name postgresql -d -p 5432:5432 --restart=always \
  -e POSTGRES_DB=artifactory -e POSTGRES_USER=artifactory -e POSTGRES_PASSWORD=password \
  -v /data1/postgresql:/var/lib/postgresql/data \
  --network artifactory \
  docker.bintray.io/postgres:9.6.11

docker run --name artifactory -d -p 8081:8081 --restart=always \
  --ulimit nofile=32000:40000 --ulimit nproc=65535 \
  -e EXTRA_JAVA_OPTIONS='-Xms512m -Xmx4g -Xss256k -XX:+UseG1GC' \
  -e DB_TYPE=postgresql -e DB_USER=artifactory -e DB_PASSWORD=password \
  -v /data1/artifactory:/var/opt/jfrog/artifactory \
  --network artifactory \
  docker.bintray.io/jfrog/artifactory-pro:latest

docker run --name nginx -d -p 80:80 -p 443:443 --restart=always \
  -v /data1/nginx/nginx.conf:/etc/nginx/nginx.conf \
  -v /data1/nginx/conf.d:/etc/nginx/conf.d \
  -v /data1/fileserver:/data1/fileserver \
  --network artifactory \
  nginx:alpine

# docker run --name nginx -d -p 80:80 -p 443:443 --restart=always \
#   -v /data1/nginx:/var/opt/jfrog/nginx \
#   -e ART_BASE_URL=http://artifactory:8081/artifactory -e SSL=true \
#   --network artifactory \
#   docker.bintray.io/jfrog/nginx-artifactory-pro:6.14.0
