#!/bin/bash

if [ $deletion_mark -ne 1 ];then

  aws elbv2 create-target-group \
    --name $TRAVIS_BRANCH \
    --protocol HTTP \
    --port 80 \
    --target-type ip \
    --vpc-id vpc-00016262d7b12e54c
  echo -e "\033[34m ALB target group created. \033[0m"

else
  echo -e "\033[31m This is a resources deletion operation. \033[0m"

fi
