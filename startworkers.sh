#!/bin/bash

docker run -d --rm --network jenkins_jenkins_network jenkinsci/jnlp-slave -url http://jenkins:8080 a87bb19d2fec1248d658706b2661a189405ef0023b8411dd6a7d40e26957d382 worker1
