#!/bin/bash

targetgrouparn=`aws elbv2 describe-target-groups | grep -w $TRAVIS_BRANCH | grep -i TargetGroupArn`
targetgrouparn=`echo ${targetgrouparn##*: \"}`
targetgrouparn=`echo ${targetgrouparn%%\"*}`

rule_arn=`aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | jq -c '.Rules[]| select(.Conditions[].Values[]| contains("'"$TRAVIS_BRANCH"'"))' | jq -r '.RuleArn'`

if [ $deletion_mark -ne 1 ];then

aws elbv2 describe-rules --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 | grep -w $TRAVIS_BRANCH 

if [ $? -ne 0 ];then
 
aws elbv2 create-rule \
    --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 \
    --priority $RANDOM \
    --conditions '{ "Field": "host-header", "HostHeaderConfig": { "Values": ["'"$TRAVIS_BRANCH"'.*"]  }  }' \
    --actions Type=forward,TargetGroupArn=$targetgrouparn
else
  echo "listener rule already exists"
  exit 0    
  
fi

else 
  aws elbv2 delete-rule \
     --rule-arn $rule_arn
fi     