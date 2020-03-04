#!/usr/bin/env bash

default_key_path='~/.ssh/id_rsa.pub'

[[ $1 =~ i-[a-z0-9]{17} ]] && IS_INSTANCE_ID=true || IS_INSTANCE_ID=false
BASTION_INSTANCE_ID='i-0c4e56d699fd24711'
INSTANCE_OR_TASK_FAMILY=$1
KEY_PATH=${3:-$default_key_path}
CLUSTER_NAME=${INSTANCE_OR_TASK_FAMILY}

if ${IS_INSTANCE_ID}; then
  echo "Sending key to instance ${1}"
  instance_id=$1
else
  echo "Sending key to instance with task: ${INSTANCE_OR_TASK_FAMILY}"

  task_arn=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} --family "${INSTANCE_OR_TASK_FAMILY}" --output text --query 'taskArns[*]')
  echo "Found task ARN: ${task_arn}"

  ci_arn=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks "${task_arn}" --output text --query 'tasks[*][containerInstanceArn]')
  echo "Found container instance ARN: ${ci_arn}"

  instance_id=$(aws ecs describe-container-instances --cluster ${CLUSTER_NAME}  --container-instances "${ci_arn}" --output text --query 'containerInstances[*][ec2InstanceId]')
fi
instance_ip=$(aws ec2 describe-instances --instance-id ${instance_id} --output text --query 'Reservations[].Instances[].PrivateIpAddress')
bastion_ip=$(aws ec2 describe-instances --instance-id ${BASTION_INSTANCE_ID} --output text --query 'Reservations[].Instances[].PublicIpAddress')
az=$(aws ec2 describe-instances --instance-id ${instance_id} --output text --query 'Reservations[].Instances[].Placement.AvailabilityZone')

echo "Found instance id: ${instance_id} ${instance_ip} ${az}"
echo "Bastion instance IP: ${bastion_ip}"
aws ec2-instance-connect send-ssh-public-key --instance-id ${BASTION_INSTANCE_ID} --ssh-public-key file://${KEY_PATH} --availability-zone ap-northeast-1a --instance-os-user ec2-user

if [[ ${INSTANCE_OR_TASK_FAMILY} != ${BASTION_INSTANCE_ID} ]]; then
  aws ec2-instance-connect send-ssh-public-key --instance-id ${instance_id} --ssh-public-key file://${KEY_PATH} --availability-zone ${az} --instance-os-user ec2-user
  echo "# Use following command to access your server:"
  echo "ssh -A -t ec2-user@${bastion_ip} ssh ${instance_ip}"
else
  echo "# Use following command to access your server:"
  echo "ssh -A ec2-user@${bastion_ip}"
fi