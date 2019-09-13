default_key_path='~/.ssh/id_rsa.pub'

CLUSTER_NAME=holidays-api-staging
BASTION_INSTANCE_ID='i-0ee20f8f6ddba8e3a'
TASK_FAMILY=$1
KEY_PATH=${3:-$default_key_path}

echo "Sending key to instance with task: ${TASK_FAMILY}\n"

task_arn=$(aws ecs list-tasks --cluster $CLUSTER_NAME --family "${TASK_FAMILY}" --output text --query 'taskArns[*]')
echo "Found task ARN: ${task_arn}"

ci_arn=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks "${task_arn}" --output text --query 'tasks[*][containerInstanceArn]')
echo "Found container instance ARN: ${ci_arn}"

instance_id=$(aws ecs describe-container-instances --cluster $CLUSTER_NAME  --container-instances "${ci_arn}" --output text --query 'containerInstances[*][ec2InstanceId]')
echo "Found instance id: ${instance_id}"
aws ec2-instance-connect send-ssh-public-key --instance-id $BASTION_INSTANCE_ID --ssh-public-key file://$KEY_PATH --availability-zone ap-northeast-1a --instance-os-user ec2-user
aws ec2-instance-connect send-ssh-public-key --instance-id $instance_id --ssh-public-key file://$KEY_PATH --availability-zone ap-northeast-1a --instance-os-user ec2-user
