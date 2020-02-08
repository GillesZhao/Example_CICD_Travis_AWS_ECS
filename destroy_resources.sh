#!/bin/bash

targetgrouparn=`aws elbv2 describe-target-groups | grep -w $TRAVIS_BRANCH | grep -i TargetGroupArn`
targetgrouparn=`echo ${targetgrouparn##*: \"}`
targetgrouparn=`echo ${targetgrouparn%%\"*}`


rule_arn=`aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | jq -c '.Rules[]| select(.Conditions[].Values[]| contains("'"$TRAVIS_BRANCH"'"))' | jq -r '.RuleArn'`

if [ $deletion_mark -eq 1 ];then

#Delete ALB listener rule
   if [ -n "$rule_arn" ];then
    aws elbv2 delete-rule \
     --rule-arn $rule_arn
    echo "ALB listener rule deleted" 
   else
    echo "ALB listener rule doesn't exist"
   fi

#Delete ALB target group 
   if [ -n "$targetgrouparn" ];then
    aws elbv2 delete-target-group \
    --target-group-arn $targetgrouparn  
    echo "ALB target group deleted" 
   else
    echo "ALB target group doesn't exist"
   fi

#Delete ECS service 
  aws ecs delete-service \
  --cluster ecs-poc \
  --service $TRAVIS_BRANCH \
  --force 

  echo "ECS service doesn't exist or already deleted"

#Delete Route53 record set 
  aws route53 change-resource-record-sets --hosted-zone-id Z14JIGC687R7OP   --change-batch '{ "Comment": "Route53 creating a record set", "Changes": [ { "Action": "DELETE", "ResourceRecordSet": { "Name": "'"$TRAVIS_BRANCH"'.juwai.xyz.", "Type": "A", "AliasTarget":{ "HostedZoneId": "Z1LMS91P8CMLE5", "DNSName": "dualstack.alb-ecs-poc-1103874013.ap-southeast-1.elb.amazonaws.com","EvaluateTargetHealth": false} } } ] }'

  if [ $? == 0 ];then
    echo "Route53 record set deleted"
  else
    echo "Route53 record set doesn't exist or already deleted"
  fi
fi

