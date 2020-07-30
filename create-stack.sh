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
  echo "Usage: ./create-stack.sh <domain-name>"
  exit 1;
fi

DOMAIN=$1

export STACK_NAME=${DOMAIN//./-}-payid

ARN=`aws acm   list-certificates --region us-east-1 --output text  | grep "\t${DOMAIN}"  | cut -f2`

if [ -z $ARN  ]; then 
  echo "${bold}No certificate found in AWS certificate manager for domain $DOMAIN${normal}"
  echo "You can request a certificate by running: ./request-certificate.sh $DOMAIN"
  exit
fi


RECORD=`aws acm describe-certificate --certificate-arn $ARN --output table  --region us-east-1 | grep Status | grep ISSUED`

if [ $? != 0 ]; then
  echo "${bold}Certificate for $DOMAIN has been requested but not issued yet by AWS certificate manager.${normal}"
  echo Please make sure you updated the DNS for your domain with the CNAME specified by the request-certificate.sh command.
  echo You can run this script again to see the expected value: ./request-certificate.sh $DOMAIN
  echo Run this script again once the certificate has been issued.
  echo
  exit 1
fi

echo Creating stack $STACK_NAME in AWS...

aws cloudformation deploy --template-file payid-stack.yaml --stack-name ${STACK_NAME} --capabilities CAPABILITY_IAM --parameter-overrides domainName=${DOMAIN}

if [ $? != 0 ]; then 
  echo "${bold}Stack deployment failed.${normal}";
  exit 1; 
fi

echo
echo Created successfully

NS=`aws cloudformation describe-stacks --stack-name ${STACK_NAME} --output text | grep nameserver | sort | cut -f 2,3`


if [ $? != 0 ]; then
  echo "${bold}Could not find nameservers for ${STACK_NAME}.${normal}";
  exit 1;
fi

echo Please update the Nameservers for your domain to
echo "${bold}${NS}${normal}"
