#!/bin/bash

if [ ! -f inventory ]
then
  echo "Missing inventory file."
  exit 1
fi

if [ ! -f terraform.tfvars ]
then
  echo "Missing terraform.tfvars file."
  exit 1
fi

IP=$(cat inventory | tail -n 1)
KEY_PRIVATE_FILE=$(cat terraform.tfvars | grep ^key_private_file | awk '{print $3}' | tr -d '"')
SSH_USER=$(cat terraform.tfvars | grep ^ssh_user | awk '{print $3}' | tr -d '"')

if [ -z $KEY_PRIVATE_FILE ]
then
  echo "Missing 'key_private_file' in terraforms.tfvars file."
  exit 1
fi

if [ -z $SSH_USER ]
then
  echo "Missing 'ssh_user' in terraforms.tfvars file."
  exit 1
fi


ssh-keygen -R $IP  > /dev/null 2>&1
ssh-keyscan -H $IP >> ~/.ssh/known_hosts 2>/dev/null
ssh -i $KEY_PRIVATE_FILE $SSH_USER@$IP
