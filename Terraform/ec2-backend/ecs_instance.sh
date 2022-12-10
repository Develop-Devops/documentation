#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=${ecs_cluster}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"