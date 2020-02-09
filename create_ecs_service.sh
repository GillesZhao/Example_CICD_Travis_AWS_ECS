#!/bin/bash

targetgrouparn=`aws elbv2 describe-target-groups | grep -w $TRAVIS_BRANCH | grep -i TargetGroupArn`
targetgrouparn=`echo ${targetgrouparn##*: \"}`
targetgrouparn=`echo ${targetgrouparn%%\"*}`

service_status=`aws ecs describe-services --cluster ecs-poc --services $TRAVIS_BRANCH | jq -r '.services[].status'`

if [ $deletion_mark -ne 1 ];then

 if [ "$service_status" != "ACTIVE" ];then
 aws ecs create-service \
--cluster ecs-poc \
--service-name $TRAVIS_BRANCH \
--task-definition $TRAVIS_BRANCH \
--load-balancers "targetGroupArn=$targetgrouparn,containerName=ecs_poc_app_python,containerPort=5000" \
--desired-count 1 \
--launch-type FARGATE \
--platform-version LATEST \
--deployment-configuration "maximumPercent=200,minimumHealthyPercent=100" \
--network-configuration "awsvpcConfiguration={subnets=[subnet-04f8f669b07b090e4,subnet-0801d41e55a936e9d,subnet-0f510f0f386b882c0],securityGroups=[sg-01b5fc974468ac57b],assignPublicIp=ENABLED}" \
--health-check-grace-period-seconds 0 \
--scheduling-strategy REPLICA \

 echo -e "\033[34m ECS service created. \033[0m"

 else
    aws ecs update-service --cluster "ecs-poc" --service "$TRAVIS_BRANCH"  --task-definition $TRAVIS_BRANCH
    echo -e "\033[34m ECS service updated with new task definition revision. \033[0m"
 fi

else
   echo -e "\033[31m This is a resources deletion operation. \033[0m"
fi  
