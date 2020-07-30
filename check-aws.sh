#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)


KEY=`aws configure list | grep access_key | grep -v "not set"`

if [ $? != 0 ]; then
  echo "${bold}Could not find aws command tool.${normal}"
  echo Please visit ${bold}https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html${normal} for help installing.
  exit 1
fi

if [ -z "$KEY" ]; then
  echo "${bold}aws cli needs to be configured with an access key.${normal}" 
  echo "Please visit ${bold}https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials${normal} to create an access key."
  echo "Then configure it by running: aws configure"
  exit 1
fi
