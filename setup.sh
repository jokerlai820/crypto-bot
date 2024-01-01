#!/bin/bash

i=1;
for parameter in "$@" 
do
  case $i in
    1)
      ENV=$parameter;
    ;;
  esac
    echo "Parameter - $i: $parameter";
    i=$((i + 1));
done

# parameters to be assigned
ENV=${ENV:="local"}
FREQTRADE_CONFIG_PATH_PREFIX=/ft_userdata/user_data/
FREQTRADE_CONFIG_FILE_NAME=config.json
FREQTRADE_CONFIG_PATH=${FREQTRADE_CONFIG_PATH:="${FREQTRADE_CONFIG_PATH_PREFIX}${FREQTRADE_CONFIG_FILE_NAME}"}
FREQTRADE_CONFIG_NAME=$FREQTRADE_CONFIG_PATH

# Retrieve config.json from pararmeter store
echo "Retrieving config.json....."
if [ "$ENV" = "local" ]; then 
  FREQTRADE_CONFIG_SORUCE_PATH=".${FREQTRADE_CONFIG_PATH_PREFIX}${ENV}.${FREQTRADE_CONFIG_FILE_NAME}"
  echo "from ${FREQTRADE_CONFIG_SORUCE_PATH}."
  FREQTRADE_CONFIG=$(cat ${FREQTRADE_CONFIG_SORUCE_PATH})
else 
  if [ -f "$FREQTRADE_CONFIG_PATH" ]; then
      echo "$FREQTRADE_CONFIG_PATH exists."
  else 
      echo "$FREQTRADE_CONFIG_PATH does not exist."
      touch "${FREQTRADE_CONFIG_PATH}"
  fi
  echo "from AWS ssm with name ${FREQTRADE_CONFIG_NAME}."
  FREQTRADE_CONFIG=$(aws ssm get-parameter --name $FREQTRADE_CONFIG_NAME --with-decryption --query 'Parameter.Value' --output text)
fi
echo "${FREQTRADE_CONFIG}" > "./${FREQTRADE_CONFIG_PATH}"
echo "The value of $FREQTRADE_CONFIG_PATH is $FREQTRADE_CONFIG"
echo "Retrieved config.json"


