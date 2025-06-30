#!/bin/bash
set -e

# Create agent directory
sudo mkdir -p /agent
cd /agent

# Download and extract agent
curl -LO https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
sudo tar xzf vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz
sudo rm vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz

# Create agent user
sudo useradd -m -s /bin/bash agentuser || true
sudo chown -R agentuser:agentuser /agent

# Create systemd service for auto-registration and running
sudo tee /etc/systemd/system/azuredevops-agent.service > /dev/null <<EOF
[Unit]
Description=Azure DevOps Agent
After=network.target

[Service]
Type=simple
User=agentuser
WorkingDirectory=/agent
ExecStartPre=/bin/bash -c '/agent/config.sh --unattended --url ${ORGANIZATION_URL} --auth pat --token ${PAT_TOKEN} --pool ${AGENT_POOL} --agent \$(hostname) --replace --acceptTeeEula'
ExecStart=/agent/run.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable azuredevops-agent.service

# Install additional tools
sudo -u agentuser bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'
sudo apt-get install -y python3-pip python3-venv