ARG JENKINS_AGENT_NAME
ARG JENKINS_URL
ARG JENKINS_SECRET
FROM jenkins/inbound-agent

USER root
RUN apt -y update && \
    apt upgrade -y && \
    apt install -y python3

USER jenkins
COPY --chown=jenkins:jenkins ./* .
RUN chmod 700 ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]