docker build -t capstoneproject/jenkins:2.235.3 -f Dockerfile.jenkinsMaster .
docker push capstoneproject/jenkins:2.235.3

docker build -t capstoneproject/inbound-agent:4.3-4 -f Dockerfile.jenkinsAgent .
docker push capstoneproject/inbound-agent:4.3-4
