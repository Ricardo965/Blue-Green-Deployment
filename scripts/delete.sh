#!/bin/bash

# Configura la región de AWS
AWS_REGION="us-east-1"

# Eliminar Elastic IPs
echo "Liberando Elastic IPs..."
aws ec2 describe-addresses --region $AWS_REGION --query 'Addresses[].AllocationId' --output text | xargs -I {} aws ec2 release-address --region $AWS_REGION --allocation-id {}

# Eliminar todas las instancias EC2
echo "Eliminando Instancias EC2..."
aws ec2 describe-instances --region $AWS_REGION --query 'Reservations[].Instances[].InstanceId' --output text | xargs -I {} aws ec2 terminate-instances --region $AWS_REGION --instance-ids {}

# Eliminar Volúmenes EBS
echo "Eliminando Volúmenes EBS..."
aws ec2 describe-volumes --region $AWS_REGION --query 'Volumes[].VolumeId' --output text | xargs -I {} aws ec2 delete-volume --region $AWS_REGION --volume-id {}

# Eliminar Dispositivos de Red (ENIs)
echo "Eliminando Dispositivos de Red (ENIs)..."
aws ec2 describe-network-interfaces --region $AWS_REGION --filters Name=vpc-id,Values=$(aws ec2 describe-vpcs --region $AWS_REGION --query 'Vpcs[0].VpcId' --output text) --query 'NetworkInterfaces[].NetworkInterfaceId' --output text | xargs -I {} aws ec2 delete-network-interface --region $AWS_REGION --network-interface-id {}

# Eliminar Subredes
echo "Eliminando Subredes..."
aws ec2 describe-subnets --region $AWS_REGION --filters Name=vpc-id,Values=$(aws ec2 describe-vpcs --region $AWS_REGION --query 'Vpcs[0].VpcId' --output text) --query 'Subnets[].SubnetId' --output text | xargs -I {} aws ec2 delete-subnet --region $AWS_REGION --subnet-id {}

# Eliminar Internet Gateways
echo "Eliminando Internet Gateways..."
aws ec2 describe-internet-gateways --region $AWS_REGION --query 'InternetGateways[].InternetGatewayId' --output text | xargs -I {} aws ec2 detach-internet-gateway --region $AWS_REGION --internet-gateway-id {} --vpc-id $(aws ec2 describe-vpcs --region $AWS_REGION --query 'Vpcs[0].VpcId' --output text)
aws ec2 describe-internet-gateways --region $AWS_REGION --query 'InternetGateways[].InternetGatewayId' --output text | xargs -I {} aws ec2 delete-internet-gateway --region $AWS_REGION --internet-gateway-id {}

# Eliminar VPC
echo "Eliminando VPC..."
aws ec2 describe-vpcs --region $AWS_REGION --query 'Vpcs[].VpcId' --output text | xargs -I {} aws ec2 delete-vpc --region $AWS_REGION --vpc-id {}

# Eliminar Clústeres EKS
echo "Eliminando Clústeres EKS..."
aws eks describe-cluster --region $AWS_REGION --query 'clusters[].name' --output text | xargs -I {} aws eks delete-cluster --region $AWS_REGION --name {}

# Eliminar Node Groups de EKS
echo "Eliminando Node Groups de EKS..."
aws eks list-nodegroups --region $AWS_REGION --query 'nodegroups' --output text | xargs -I {} aws eks delete-nodegroup --region $AWS_REGION --cluster-name devopsshack-cluster --nodegroup-name {}

# Eliminar Addons de EKS
echo "Eliminando Addons de EKS..."
aws eks describe-cluster --region $AWS_REGION --name devopsshack-cluster --query 'cluster.addons' --output text | xargs -I {} aws eks delete-addon --region $AWS_REGION --cluster-name devopsshack-cluster --addon-name {}

# Eliminar Security Groups (excepto los predeterminados)
echo "Eliminando Security Groups..."
aws ec2 describe-security-groups --region $AWS_REGION --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text | xargs -I {} aws ec2 delete-security-group --region $AWS_REGION --group-id {}

# Eliminar IAM Roles
echo "Eliminando IAM Roles..."
aws iam list-roles --query 'Roles[].RoleName' --output text | xargs -I {} aws iam delete-role --role-name {}

# Eliminar Políticas IAM
echo "Eliminando Políticas IAM..."
aws iam list-policies --query 'Policies[].Arn' --output text | xargs -I {} aws iam delete-policy --policy-arn {}

# Eliminar Lambda Functions
echo "Eliminando Funciones Lambda..."
aws lambda list-functions --query 'Functions[].FunctionName' --output text | xargs -I {} aws lambda delete-function --function-name {}

# Eliminar Buckets S3
echo "Eliminando Buckets S3..."
aws s3 ls | awk '{print $3}' | xargs -I {} aws s3 rb s3://{} --force

# Eliminar Tablas DynamoDB
echo "Eliminando Tablas DynamoDB..."
aws dynamodb list-tables --query 'TableNames' --output text | xargs -I {} aws dynamodb delete-table --table-name {}

# Eliminar Elastic Load Balancers (ELB y ALB)
echo "Eliminando Elastic Load Balancers..."
aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].LoadBalancerName' --output text | xargs -I {} aws elb delete-load-balancer --load-balancer-name {}
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text | xargs -I {} aws elbv2 delete-load-balancer --load-balancer-arn {}

# Eliminar Elastic Beanstalk
echo "Eliminando Elastic Beanstalk..."
aws elasticbeanstalk describe-environments --query 'Environments[].EnvironmentName' --output text | xargs -I {} aws elasticbeanstalk terminate-environment --environment-name {}

# Eliminar Elasticache
echo "Eliminando Elasticache..."
aws elasticache describe-cache-clusters --query 'CacheClusters[].CacheClusterId' --output text | xargs -I {} aws elasticache delete-cache-cluster --cache-cluster-id {}

# Eliminar Redshift
echo "Eliminando Clústeres Redshift..."
aws redshift describe-clusters --query 'Clusters[].ClusterIdentifier' --output text | xargs -I {} aws redshift delete-cluster --cluster-identifier {} --skip-final-cluster-snapshot
