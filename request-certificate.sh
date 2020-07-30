#!/bin/bash

BASEDIR=$(dirname "$0")
$BASEDIR/check-aws.sh

if [ $? != 0 ]; then
  exit 1;
fi

bold=$(tput bold)
normal=$(tput sgr0)


if [ $# != 1 ]; then
  echo "${bold}Domain name required!${normal}"
  echo "Usage: ./request-certificate.sh <domain-name>"
  exit 1;
fi

DOMAIN=$1

echo Requesting certificate for $DOMAIN

ARN=`aws acm request-certificate --region us-east-1 --validation-method DNS --domain-name $DOMAIN --output text`

if [ $? != 0 ]; then
  echo "${bold}Certificate request failed.${normal}"
  exit 1
fi

# seems like there is a second delay before the cert can be queried
sleep 5

RECORD=`aws acm describe-certificate --certificate-arn $ARN --output text | grep RESOURCERECORD | cut -f 2-`

if [ $? != 0 ]; then
  echo "${bold}Failed to lookup resource record for certificate${normal}"
  exit 1
fi

echo Certificate requested. Please create the following CNAME record for your domain:
echo "${bold}$RECORD${normal}"
