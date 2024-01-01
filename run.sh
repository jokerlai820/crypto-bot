#!/bin/bash

i=1;
for parameter in "$@" 
do
  case $i in
    1)
      ENV=$parameter;
    ;;
    2)
      STRATEGY=$parameter;
    ;;
  esac
    echo "Parameter - $i: $parameter";
    i=$((i + 1));
done

# parameters to be assigned
ENV=${ENV:="local"}
STRATEGY=${STRATEGY:="SampleStrategy"}
DOCKER_FILE=${DOCKER_FILE:="docker-compose.$ENV.yml"}

./setup.sh $ENV

# Change to the directory where freqtrade is installed
cd ft_userdata

echo "Execute $DOCKER_FILE"
echo "Loaded $STRATEGY"
# Start freqtrade
sudo STRATEGY=$STRATEGY docker-compose -f $DOCKER_FILE up -d
