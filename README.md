# PayID via AWS Lambda

Ready to get started with your own PayID server on AWS Lambda?

You'll need:
* an AWS account
* a domain you want to use for your Pay IDs
* a certificate imported into Amazon Certificate Manager (you'll need the ARN to pass to the stack)
* to update your domain to use Amazon's name servers in the Route53 hosted zone that's created for you

If you have the domain and certificate, and you're okay with using Amazon's name servers, then click the button below to get started. 

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://us-west-1.console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/create/review?templateURL=https://raw.githubusercontent.com/xpring-eng/payid-lambda/master/payid-stack.yaml?token=AAKSGXLGFNK7LYBIJL53QH27ENQVO&stackName=my-payid-server)


