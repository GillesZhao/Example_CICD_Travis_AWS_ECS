#!/bin/bash

aws elbv2 create-target-group \
    --name $TRAVIS_BRANCH \
    --protocol HTTP \
    --port 80 \
    --target-type ip \
    --vpc-id vpc-00016262d7b12e54c