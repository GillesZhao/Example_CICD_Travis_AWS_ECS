#!/bin/bash

rule_arn=`aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | jq -c '.Rules[]| select(.Conditions[].Values[]| contains("'"$TRAVIS_BRANCH"'"))' | jq -r '.RuleArn'`

if [ $deletion_mark -eq 1 ];then

#Delete ALB listener rules
   if [ $rule_arn != "" ];then
    aws elbv2 delete-rule \
     --rule-arn $rule_arn
  fi

#Delete ALB target group 
  aws elbv2 delete-target-group \
    --target-group-arn $targetgrouparn  

#Delete ECS service 
  aws ecs delete-service \
  --cluster ecs-poc \
  --service $TRAVIS_BRANCH \
  --force 

#Delete Route53 record set 
  aws route53 change-resource-record-sets --hosted-zone-id Z14JIGC687R7OP   --change-batch '{ "Comment": "Route53 creating a record set", "Changes": [ { "Action": "DELETE", "ResourceRecordSet": { "Name": "'"$TRAVIS_BRANCH"'.juwai.xyz.", "Type": "A", "AliasTarget":{ "HostedZoneId": "Z1LMS91P8CMLE5", "DNSName": "dualstack.alb-ecs-poc-1103874013.ap-southeast-1.elb.amazonaws.com","EvaluateTargetHealth": false} } } ] }'

fi

