#!/bin/bash

if [ $deletion_mark -ne 1 ];then

aws route53 change-resource-record-sets --hosted-zone-id Z14JIGC687R7OP --change-batch '{ "Comment": "Route53 creating a record set", "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'"$TRAVIS_BRANCH"'.juwai.xyz.", "Type": "A", "AliasTarget":{ "HostedZoneId": "Z1LMS91P8CMLE5", "DNSName": "dualstack.alb-ecs-poc-1103874013.ap-southeast-1.elb.amazonaws.com","EvaluateTargetHealth": false} } } ] }'

echo -e "\033[34m Route53 alias DNS A record created. \033[0m"

exit 0

else
  echo -e "\033[31m This is a resources deletion operation. \033[0m"

fi
