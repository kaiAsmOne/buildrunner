#!/bin/sh
echo $@
echo "---------------------------------------------"
echo "Ansible Deploy Machine for Azure Piplelines"
echo "By Kai Thorsrud, Sicra A/S https://sicra.no/ "
echo "---------------------------------------------"
#Install System Packages
/bin/su - $4 -c "yum check-update"
sudo yum install -y gcc libffi-devel python3 epel-release
sudo yum install -y python3-pip wget python3-devel krb5-devel sshpass git
sudo yum clean all
#Install PIP & Ansible 
sudo pip3 install --upgrade pip
/bin/su - $4 -c "pip3 install --upgrade virtualenv"
/bin/su - $4 -c "pip3 install pywinrm[kerberos]"
/bin/su - $4 -c "pip3 install pywinrm"
/bin/su - $4 -c "pip3 install requests"
/bin/su - $4 -c "pip3 install ansible"
# Note: Not possible to install ansible azure galaxy collection with az cli due to dep. issues. 
# Bug: https://github.com/ansible-collections/azure/issues/477
# Bug: https://github.com/ansible-collections/azure/issues/130
# Bug: https://github.com/ansible-collections/azure/issues/648
# Solution: Checkout Ansible Galaxy Azure Project from github and build the unreleased version
#ansible-galaxy install mindpointgroup.rhel7_cis
#ansible-galaxy install mindpointgroup.windows_2016_cis
#ansible-galaxy install mindpointgroup.ubuntu20_cis
#ansible-galaxy install mindpointgroup.windows_2019_cis
#ansible-galaxy install mindpointgroup.rhel8_cis
/bin/su - $4 -c "git clone https://github.com/ansible-collections/azure.git"
/bin/su - $4 -c "ansible-galaxy collection build azure/ --force"
/bin/su - $4 -c "ansible-galaxy collection install azure-azcollection-*.tar.gz --force"
/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.rhel7_cis"
/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.rhel8_cis"

/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.windows_2016_cis"
/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.ubuntu20_cis"
/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.windows_2019_cis"
/bin/su - $4 -c "ansible-galaxy collection install mindpointgroup.ubuntu20_cis"

/bin/su - $4 -c "pip3 install azure-cli==2.34.0"
/bin/su - $4 -c "az login --service-principal -u $1 -p $2 --tenant $3"
/bin/su - $4 -c "pip3 install google-auth"

#Install Azure Devops Agent
cd /home/$4
mkdir agent
cd agent
AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
wget -O agent.tar.gz ${AGENTURL} 
tar zxvf agent.tar.gz
chmod -R 777 .
sudo /bin/su -c "/home/$4/agent/bin/installdependencies.sh"
/bin/su -c "/home/$4/agent/config.sh --unattended --url '$5' --auth pat --token '$6' --pool '$7' --agent $HOSTNAME --acceptTeeEula --work ./_work --runAsService --acceptTeeEula --replace" - $4
sudo ./svc.sh install $4
sudo ./svc.sh start
# Load Token for use with Google Cloud
cd /home/$4
mkdir gcp
chown -R $4:$4 gcp/
/bin/su - $4 -c "az keyvault secret download --name '$8' --vault-name '$9' -f /home/$4/gcp/gcpcredz.json"
echo "export GCP_SERVICE_ACCOUNT_FILE=/home/$4/gcp/gcpcredz.json" >> /home/$4/.bashrc
echo "export GCP_AUTH_KIND=serviceaccount" >> /home/$4/.bashrc
echo "export ANSIBLE_HOST_KEY_CHECKING=False" >> /home/$4/.bashrc
#Configure Ansible Defaults
sudo mkdir /etc/ansible/
cd /etc/ansible/
sudo curl -O https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
sudo sed -i "s/#host_key_checking = True/host_key_checking = False/" /etc/ansible/ansible.cfg
cd /home/$4
/bin/su - $4 -c "pip3 install -r azure/requirements-azure.txt"
exit 0

