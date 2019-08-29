# Clair - Docker Image Scan
[![CircleCI](https://circleci.com/gh/kiseru-io/clair-sec-scanner.svg?style=svg)](https://circleci.com/gh/kiseru-io/clair-sec-scanner)

Run a security scan in a single command

### Standalone
```
IMAGE=nginx:latest docker-compose run clair-scanner
```
Default failure is for Critical. If you want to fail the build at a lower level, you can set the LEVEL e.g. Low | Medium | High | Critical

```
IMAGE=nginx:latest LEVEL=High docker-compose run clair-scanner
```

When running with docker-compose up ensure that you're using the --abort-on-container-exit docker-compose option otherwise it will never exit, and will block your CI/CD process. e.g
```
LEVEL=High IMAGE=node:lts-slim docker-compose up --force-recreate --abort-on-container-exit
```

docker cp ./cve-whitelist.yaml $(IMAGE=mmodevdexregistry.azurecr.io/sds-fa-service:690d45058aa7455bd3e626773fa1ab2761912e7d LEVEL=High docker-compose -f docker-compose-clair.yml ps -q clair-scanner):/tmp/cve-whitelist.yaml


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

### CVE Whitelisting
If you wish to whitelist and ignore a CVE, the scanner looks for a whitelist file named cve-whitelist.yaml stored in the current working directory. The format is:

```
generalwhitelist:
  CVE-2018-15686: imagemagic    # Critical
  CVE-2019-12834: some libc bug # High

```
If no cve-whitelist.yaml file exists, an empty example one will be created by default.

### CircleCI and CVE Whitelisting
If you wish to whitelist using CircleCI and require the use of a docker executor, you may be aware that CircleCI does not support mounting the host volume, and therfore the only way to provide the whitelist file is to use a docker copy. If this is the case, your circleci config may look similar to:

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
            docker cp ./cve-whitelist.yaml $(IMAGE=nginx:latest docker-compose ps -q clair-scanner):/tmp/cve-whitelist.yaml
            IMAGE=$DOCKER_IMAGE_NAME:$CIRCLE_SHA1 WHITELIST=/tmp/cve-whitelist.yaml docker-compose up --abort-on-container-exit

```

For further info see:
- https://circleci.com/docs/2.0/building-docker-images/#mounting-folders


### CircleCI Orb
TODO:


### Example Output
```
clair-scanner_1  | 2019/07/19 00:29:40 [INFO] ▶ Server listening on port 9279
clair-scanner_1  | 2019/07/19 00:29:40 [INFO] ▶ Analyzing 201c931a89f4b16db9d831f8a7e515c170ce750888f414a38433a3cd241a781e
clair-scanner_1  | 2019/07/19 00:29:58 [INFO] ▶ Analyzing f4bb9f4a20ebc7c66db58b4d5522a21e4d3677b29ba2b4b300894ca4ea2bbfb8
clair-scanner_1  | 2019/07/19 00:29:59 [INFO] ▶ Analyzing ae0ab05202709b25da97cf88c1715143e96fcd8da2c6efcf4a60fe92a62caa86
...

clair-scanner_1  | 2019/07/19 00:29:59 [WARN] ▶ Image [nginx:latest] contains 67 total vulnerabilities
clair-scanner_1  | 2019/07/19 00:29:59 [ERRO] ▶ Image [nginx:latest] contains 1 unapproved vulnerabilities
clair-scanner_1  | +------------+-----------------------------+---------------+-----------------+--------------------------------------------------------------+
clair-scanner_1  | | STATUS     | CVE SEVERITY                | PACKAGE NAME  | PACKAGE VERSION | CVE DESCRIPTION                                              |
clair-scanner_1  | +------------+-----------------------------+---------------+-----------------+--------------------------------------------------------------+
clair-scanner_1  | | Unapproved | High CVE-2019-11068         | libxslt       | 1.1.32-2        | libxslt through 1.1.33 allows bypass of a protection         |
clair-scanner_1  | |            |                             |               |                 | mechanism because callers of xsltCheckRead and               |
clair-scanner_1  | |            |                             |               |                 | xsltCheckWrite permit access even upon receiving a -1        |
clair-scanner_1  | |            |                             |               |                 | error code. xsltCheckRead can return -1 for a crafted URL    |
clair-scanner_1  | |            |                             |               |                 | that is not actually invalid and is subsequently loaded.     |
clair-scanner_1  | |            |                             |               |                 | https://security-tracker.debian.org/tracker/CVE-2019-11068   |
clair-scanner_1  | +------------+-----------------------------+---------------+-----------------+--------------------------------------------------------------+
clair-scanner_1  | | Approved   | Medium CVE-2019-12904       | libgcrypt20   | 1.8.4-5         | In Libgcrypt 1.8.4, the C implementation                     |
clair-scanner_1  | |            |                             |               |                 | of AES is vulnerable to a flush-and-reload                   |
clair-scanner_1  | |            |                             |               |                 | side-channel attack because physical addresses               |
clair-scanner_1  | |            |                             |               |                 | are available to other processes. (The C                     |
clair-scanner_1  | |            |                             |               |                 | implementation is used on platforms where an                 |
clair-scanner_1  | |            |                             |               |                 | assembly-language implementation is unavailable.)            |
clair-scanner_1  | |            |                             |               |                 | https://security-tracker.debian.org/tracker/CVE-2019-12904   |
clair-scanner_1  | +------------+-----------------------------+---------------+-----------------+--------------------------------------------------------------+
clair-scanner_1  | | Approved   | Medium CVE-2019-3844        | systemd       | 241-5           | It was discovered that a systemd service that                |
clair-scanner_1  | |            |                             |               |                 | uses DynamicUser property can get new privileges             |
clair-scanner_1  | |            |                             |               |                 | through the execution of SUID binaries, which                |
clair-scanner_1  | |            |                             |               |                 | would allow to create binaries owned by the service          |
clair-scanner_1  | |            |                             |               |                 | transient group with the setgid bit set. A local             |
clair-scanner_1  | |            |                             |               |                 | attacker may use this flaw to access resources that          |
clair-scanner_1  | |            |                             |               |                 | will be owned by a potentially different service             |
clair-scanner_1  | |            |                             |               |                 | in the future, when the GID will be recycled.                |
clair-scanner_1  | |            |                             |               |                 | https://security-tracker.debian.org/tracker/CVE-2019-3844    |
clair-scanner_1  | +------------+-----------------------------+---------------+-----------------+--------------------------------------------------------------+
```
