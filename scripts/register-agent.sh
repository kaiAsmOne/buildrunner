#!/bin/bash

# This script runs on VM startup to register the agent
# It uses Azure IMDS to get unique VM info

AGENT_NAME=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2021-02-01&format=text")
ORGANIZATION_URL="${ORGANIZATION_URL}"
PAT_TOKEN="${PAT_TOKEN}"
POOL_NAME="${POOL_NAME:-KaiAgents}"

cd /agent

# Configure the agent
./config.sh \
  --unattended \
  --url "$ORGANIZATION_URL" \
  --auth pat \
  --token "$PAT_TOKEN" \
  --pool "$POOL_NAME" \
  --agent "$AGENT_NAME" \
  --replace \
  --acceptTeeEula

# Start the agent
./run.sh &