#!/bin/bash
aws elbv2 create-rule \
    --listener-arn arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:listener/app/alb-ecs-poc/4dc026513826bb09/5e24430998b64e52 \
    --priority 10 \
    --conditions '{ "Field": "host-header", "HostHeaderConfig": { "Values": ["hw-288.*"]  }  }' \
    --actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:ap-southeast-1:468969217647:targetgroup/hw-2888/7a77be6b294ef1b7