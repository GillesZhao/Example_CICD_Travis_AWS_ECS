#!/bin/bash

alb_target_group=`aws elbv2  describe-target-groups --load-balancer-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:loadbalancer/app/alb-ecs-poc/4dc026513826bb09 |jq -c '.TargetGroups[]|select(.TargetGroupName| contains("'"$TRAVIS_BRANCH"'"))' | jq -r '.TargetGroupName'`

if [ $deletion_mark -ne 1 ];then
  if [ -z $alb_target_group ];then
  aws elbv2 create-target-group \
    --name $TRAVIS_BRANCH \
    --protocol HTTP \
    --port 80 \
    --target-type ip \
    --vpc-id vpc-00016262d7b12e54c
  echo -e "\033[34m ALB target group created. \033[0m"
  else
  echo -e "\033[31m ALB target group already exist. \033[0m"
  fi
else
  echo -e "\033[31m This is a resources deletion operation. \033[0m"

fi
