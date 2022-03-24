# Setting up a Jenkins playgroud

## Purpose of this document

I have created this short tutorial for anyone who wants to test, improve knowledge, try something new about Jenkins CI/CD v2. The setup contains a Jenkins server a basic worker node and a PyTest capable worker node.

### Steps to complete

1. Setup Jenkins server node
2. Add a simple worker node
3. Add a Python capable worker node
4. Create CI pipeline
   1. Clone test repository from GitHub
   2. Run a simple test case with PyTest
5. Investigate further improvement possibilities

## Requirements

- Docker Desktop installed
- Internet connection
- basic knowledge about Docker
- some understanding of Docker compose and docker-compose.yml file structure

## Used tools and Docker images

- Monitored for vulnerabilities by Bitnami
- Pre-configured images for general usage

Additional tool is your favourite text editor and a shell. As a Linux fan I prefer Git Bash and VS Code.

## Let's start

We are using Docker compose to create the necessary services. First is the Jenkins server:

```yaml
version: "2"

services:
  jenkins:
    image: jenkins/jenkins:lts-jdk11 # or bitnami/jenkins:latest
    ports:
      - "8050:8080"
      - "8043:8443" # For Bitnami container using HTTPS
      # - '50000:50000' # Enable JNLP port if you want to attach external workers using host networking
    volumes:
      - "jenkins_home:/var/jenkins_home"
      # - './server-scripts:/usr/share/jenkins/ref'
    environment:
      JENKINS_HOME: /var/jenkins_home # For Bitnami
    networks:
      - jenkins-network
```

As the JNLP port is not exposed by default we are able to reach the JNLP functionality from inside `jenkins-network` only. After starting the stack with:

```bash
docker-compose up --build
```

the server will be available on [http://localhost:8050/](https://localhost:8050/)

and we can unlock the UI by copying the administrator password appeared on the container's console. Next we could create a real admin user and initialize the plugins if necessary (recommended). If the plugin installation fails first time try it again.

![setup](doc/images/001_plugins.png)

After completion of the initialization we are able to add nodes and setup the enviromnent in the following way. Here is the initial dashboard of our brand new Jenkins:

![dash](doc/images/002_dashboard.png)

### Setup the worker nodes

#### Base node

Now we are able to setup the worker nodes. Click on **Set up an agent** button then configure the first agent as you see below:

![newnode](doc/images/003_nodecreate.png)

![nodesetup](doc/images/004_workernode.png)

#### Python node

Like in the previous step setup another agent but add a `python` label separated by space.

### Add the worker nodes to the stack

#### Base node

Add two new sections to your `docker-compose.yml`. First for the base node:

```yaml
node1:
  build:
    context: ./nodes/base-worker
    dockerfile: Dockerfile
  environment:
    JENKINS_URL: http://jenkins:8080
    JENKINS_AGENT_NAME: worker-base1
    JENKINS_SECRET: # include your key from the Jenkins server and restart the stack - the worker should be connected to Jenkins server
  networks:
    - jenkins-network
  profiles:
    - nodes
```

Your `nodes/base-worker` directory should contain these files:

- A `Dockerfile`

  ```Dockerfile
  ARG JENKINS_AGENT_NAME
  ARG JENKINS_URL
  ARG JENKINS_SECRET
  FROM jenkinsci/jnlp-slave

  USER jenkins
  COPY --chown=jenkins:jenkins ./* .
  RUN chmod 700 ./wait-for-it.sh && \
      chmod 700 ./entrypoint.sh
  ENTRYPOINT ["./entrypoint.sh"]
  ```

- And the `entrypoint.sh` - we need to wait some time before starting the agent for the complete server initialization.

  ```bash
  #!/bin/bash

  echo "Waiting for the server..."
  sleep 30
  echo "Staring the agent..."
  /usr/local/bin/jenkins-agent \
      -url ${JENKINS_URL} \
      ${JENKINS_SECRET} \
      ${JENKINS_AGENT_NAME}
  ```

#### Python node

- `docker-compose.yml` service addition
  ```
  node2:
  build:
    context: ./nodes/pytest-worker
    dockerfile: Dockerfile
  environment:
    JENKINS_URL: http://jenkins:8080
    JENKINS_AGENT_NAME: worker-pytest1
    JENKINS_SECRET: # insert here
  networks:
    - jenkins-network
  profiles:
    - nodes
  ```
- `Dockerfile` in `nodes/pytest-worker`

  ```Dockerfile
  ARG JENKINS_AGENT_NAME
  ARG JENKINS_URL
  ARG JENKINS_SECRET
  FROM jenkinsci/jnlp-slave

  # Add the Python layer
  FROM bitnami/python:3.10

  USER jenkins
  COPY --chown=jenkins:jenkins ./* .
  RUN chmod 700 ./wait-for-it.sh && \
      chmod 700 ./entrypoint.sh
  ENTRYPOINT ["./entrypoint.sh"]
  ```

- `entrypoint.sh` in `nodes/pytest-worker` is the same as used in the base-node

**Do not forget to insert the node secrets and node names** to the compose file. The secrets are available in Jenkins from **Dashboard => Manage Jenkins => Manage Nodes and Clouds** ([Manage Nodes page](http://localhost:8050/computer))

Restart your docker stack with nodes profile:

```bash
docker-compose --profile nodes up
```

Then login to the Jenkins server again. On the dashboard you will see the connected workers under the **Build Executor Status** section on the sidebar.

Now we completed the server and node setup.
