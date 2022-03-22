#!/bin/bash

echo "Waiting for the server..."
sleep 30
echo "Staring the agent..."
/usr/local/bin/jenkins-agent \
    -url ${JENKINS_URL} \
    ${JENKINS_SECRET} \
    ${JENKINS_AGENT_NAME}

