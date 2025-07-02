#!/bin/bash
set -e

# This script builds the same image as Microsoft-hosted runners
# using the official runner-images repository

RUNNER_IMAGES_REPO="https://github.com/actions/runner-images.git"
IMAGE_TYPE="ubuntu-22.04"  # or ubuntu-20.04, windows-2022, etc.

# Clone the repository
git clone $RUNNER_IMAGES_REPO
cd runner-images

# Install Packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer

# Build the image
cd images/ubuntu
packer build \
  -var "client_id=$ARM_CLIENT_ID" \
  -var "client_secret=$ARM_CLIENT_SECRET" \
  -var "tenant_id=$ARM_TENANT_ID" \
  -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
  -var "managed_image_resource_group_name=$RESOURCE_GROUP" \
  -var "location=$LOCATION" \
  -var "vm_size=Standard_D4s_v4" \
  ubuntu-22.04.pkr.hcl