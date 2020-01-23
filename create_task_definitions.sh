#!/bin/bash

#--cli-input-json  file://task_definition.json

aws ecs register-task-definition \
--family $TRAVIS_BRANCH \
--task-role-arn arn:aws:iam::468969217647:role/AmazonECSTaskExecutionRole \
--execution-role-arn arn:aws:iam::468969217647:role/AmazonECSTaskExecutionRole \
--network-mode awsvpc \
--requires-compatibilities "FARGATE" \
--cpu 256 \
--memory 512 \
--container-definitions \
"[
{
    \"name\": \"ecs_poc_app_python\",
    \"image\": \"$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$python_NAME:$TRAVIS_BRANCH\",
    \"cpu\": 0,
    \"memory\": 100,
    \"portMappings\": [
      {
        \"containerPort\": 5000,
        \"hostPort\": 5000
      }
    ],
    \"logConfiguration\": {
      \"logDriver\": \"awslogs\",
      \"options\": {
        \"awslogs-region\": \"ap-southeast-1\",
        \"awslogs-group\": \"ecs_poc\",
        \"awslogs-stream-prefix\": \"complete-ecs\"
      }
    }
  },
  {
    \"name\": \"ecs_poc_app_redis\",
    \"image\": \"$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$redis_NAME:$TRAVIS_BRANCH\",
    \"cpu\": 0,
    \"memory\": 100,
    \"portMappings\": [
      {
        \"containerPort\": 6379,
        \"hostPort\": 6379
      }
    ],
    \"logConfiguration\": {
      \"logDriver\": \"awslogs\",
      \"options\": {
        \"awslogs-region\": \"ap-southeast-1\",
        \"awslogs-group\": \"ecs_poc\",
        \"awslogs-stream-prefix\": \"complete-ecs\"
      }
    }
  }
]"

# "requiresCompatibilities": [
#             "FARGATE"
#         ]
# }
