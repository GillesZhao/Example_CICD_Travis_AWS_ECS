#!/bin/bash

targetgrouparn=`aws elbv2 describe-target-groups | grep -w $TRAVIS_BRANCH | grep -i TargetGroupArn`
targetgrouparn=`echo ${targetgrouparn##*: \"}`
targetgrouparn=`echo ${targetgrouparn%%\"*}`


rule_arn=`aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | jq -c '.Rules[]| select(.Conditions[].Values[]| contains("'"$TRAVIS_BRANCH"'"))' | jq -r '.RuleArn'`

service_status=`aws ecs describe-services --cluster ecs-poc --services $TRAVIS_BRANCH | jq -r '.services[].status'`

if [ $deletion_mark -eq 1 ];then

#Delete ALB listener rule
   if [ -n "$rule_arn" ];then
    aws elbv2 delete-rule \
     --rule-arn $rule_arn
    echo -e "\033[31m ALB listener rule deleted \033[0m"
   else
    echo -e "\033[31m ALB listener rule doesn't exist or already deleted \033[0m"
   fi

#Delete ALB target group
   if [ -n "$targetgrouparn" ];then
    aws elbv2 delete-target-group \
    --target-group-arn $targetgrouparn
    echo -e "\033[31m ALB target group deleted \033[0m"
   else
    echo -e "\033[31m ALB target group doesn't exist or already deleted \033[0m"
   fi

#Delete ECS service
   if [ "$service_status" == "ACTIVE" ];then
     aws ecs delete-service \
      --cluster ecs-poc \
      --service $TRAVIS_BRANCH \
      --force
     echo -e "\033[31m ECS service deleted \033[0m"
   else
     echo -e "\033[31m ECS service doesn't exist or already deleted \033[0m"
   fi

#Delete Route53 record set
TRAVIS_BRANCH_LOWER_CASE=`echo $TRAVIS_BRANCH | tr 'A-Z' 'a-z'`

route53_alias=`aws route53 list-resource-record-sets --hosted-zone-id Z14JIGC687R7OP | jq -c '.ResourceRecordSets[]| select(.Name| contains("'"$TRAVIS_BRANCH_LOWER_CASE"'"))' | jq -r .Name | grep -iw $TRAVIS_BRANCH`

   if [ -n "$route53_alias" ];then
     aws route53 change-resource-record-sets \
      --hosted-zone-id Z14JIGC687R7OP \
      --change-batch '{ "Comment": "Route53 creating a record set", "Changes": [ { "Action": "DELETE", "ResourceRecordSet": { "Name": "'"$TRAVIS_BRANCH"'.juwai.xyz.", "Type": "A", "AliasTarget":{ "HostedZoneId": "Z1LMS91P8CMLE5", "DNSName": "dualstack.alb-ecs-poc-1103874013.ap-southeast-1.elb.amazonaws.com","EvaluateTargetHealth": false} } } ] }'

      echo -e "\033[31m Route53 record set deleted \033[0m"
   else
    echo -e "\033[31m Route53 record set doesn't exist or already deleted \033[0m"
   fi



#Delete task definition
task_def_arn=`aws ecs describe-task-definition --task-definition $TRAVIS_BRANCH | jq -r .taskDefinition.taskDefinitionArn` 

  if [ -n "$task_def_arn" ];then
    while [ "$task_def_arn" != "" ]; do 
      aws ecs deregister-task-definition --task-definition $task_def_arn
      task_def_arn=`aws ecs describe-task-definition --task-definition $TRAVIS_BRANCH | jq -r .taskDefinition.taskDefinitionArn`
    done

    echo -e "\033[31m Task definition deleted \033[0m"
  else
    echo -e "\033[31m Task definition doesn't exist or already deleted \033[0m"
   fi 

else
  echo -e "\033[31m This is a resources creation operation. Nothing will be destroyed. \033[0m"
fi
