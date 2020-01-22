#!/bin/bash

aws ecs register-task-definition --family $TRAVIS_BRANCH --task-role-arn arn:aws:iam::468969217647:role/AmazonECSTaskExecutionRole --execution-role-arn arn:aws:iam::468969217647:role/AmazonECSTaskExecutionRole --network-mode awsvpc --requires-compatibilities "FARGATE" --cpu 256 --memory 512 --cli-input-json  file://task_definition.json