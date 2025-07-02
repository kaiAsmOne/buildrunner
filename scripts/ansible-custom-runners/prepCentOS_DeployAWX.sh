#!/bin/sh
echo $@
echo "---------------------------------------------"
echo "Ansible Deploy Machine for Azure Piplelines"
echo "By Kai Thorsrud, Sicra A/S https://sicra.no/ "
echo "---------------------------------------------"
#Install System Packages
/bin/su - $1 -c "yum check-update"
sudo yum install -y gcc libffi-devel python3 epel-release
sudo yum install -y python3-pip wget python3-devel krb5-devel sshpass git
sudo yum clean all
#Install PIP & Ansible 
sudo pip3 install --upgrade pip
/bin/su - $1 -c "pip3 install --upgrade virtualenv"
/bin/su - $1 -c "pip3 install pywinrm[kerberos]"
/bin/su - $1 -c "pip3 install pywinrm"
/bin/su - $1 -c "pip3 install requests"
/bin/su - $1 -c "pip3 install ansible"
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
exit 0

