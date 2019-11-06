docker run -d --name jenkins -p 8080:8080 -p 50000:50000 --restart=always \
  --group-add `stat -c %g /var/run/docker.sock` \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  deskoh/jenkins-docker
