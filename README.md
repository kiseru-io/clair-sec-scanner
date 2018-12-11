# Clair - Docker Image Scan

Run a security scan in a single command

### Standalone
```
IMAGE=nginx:latest docker-compose run clair-scanner
```
Default failure is for Critical. If you want to fail the build at a lower level, you can set the LEVEL e.g. Low | Medium | High | Critical

```
IMAGE=nginx:latest LEVEL=High docker-compose run clair-scanner
```


### CircleCI

Add a section to your config.yml such as:

```
  run-clair:
    docker:
      - image: circleci/buildpack-deps

    environment:
      DOCKER_IMAGE_NAME: nginx 

    steps:
      - checkout
      - setup_remote_docker
      - run:
          name: Run Security Test suite
          command: |
            docker pull $DOCKER_IMAGE_NAME:$CIRCLE_SHA1
            curl https://raw.githubusercontent.com/kiseru-io/clair-sec-scanner/master/docker-compose.yml -o docker-compose.yml
            IMAGE=$DOCKER_IMAGE_NAME:$CIRCLE_SHA1 docker-compose run clair-scanner

```

### CircleCI Orb
...
