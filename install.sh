#! /bin/bash

if [ ! -f /usr/local/bin/aws ] && [ ! -f /usr/local/bin/aws ]; then
  echo "This script requires the AWS CLI utility to be installed first."
  exit
fi

