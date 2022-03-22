ARG JENKINS_AGENT_NAME
ARG JENKINS_URL
ARG JENKINS_SECRET
FROM jenkinsci/jnlp-slave

USER jenkins
COPY --chown=jenkins:jenkins ./* .
RUN chmod 700 ./wait-for-it.sh && \
    chmod 700 ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]