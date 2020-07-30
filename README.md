# PayID via AWS Lambda

Ready to get started with your own PayID server on AWS Lambda?

You'll need:
* an AWS account.
* a domain you want to use for your Pay IDs.
* [a certificate imported into Amazon Certificate Manager in the `us-east-1` region](#how-do-i-get-a-certificate-in-amazon-certificate-manager). 
* __after the stack is added__, you'll have [to update your domain to use Amazon's name servers in the Route53 hosted zone that's created for you](#how-do-i-update-my-domains-nameservers-for-my-payid-domain).

Here's an example of what the form looks like: all you'll need is the domain you want to use for Pay IDs.

![stack form](./help-images/stack-form.png)

If you have the domain and certificate, and you're okay with using Amazon's name servers, then click the button below to get started. 

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://us-west-1.console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?templateURL=https://payid-server-template.s3-us-west-2.amazonaws.com/payid-stack.yaml&stackName=my-payid-server)

If you'd prefer to use the AWS command line to create your stack, we have scripts to make your life easier. [Check out our instructions for using them.](#launching-using-scripts)

## How do I get a certificate in Amazon Certificate Manager?

Note: this is a set of instructions known to work by those who created this stack, but there are likely other ways of importing a certificate. This guide only seeks to show the steps for the one used during our development of this CloudFormation stack.

### Step 1: Open up the Certificate Manager in the AWS console in us-east-1

Note: this __must__ be added in the `us-east-1` region or the CloudFormation will not create your stack/PayID server correctly. The reason for this is that the Lambda uses API Gateway for HTTP access which leverages a Cloudfront distribution for pointing a domain to it, and Cloudfront distributions require ACM certs to exist in `us-east-1.  This is mentioned on the AWS documentation [here](https://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html).

Link to console:
https://console.aws.amazon.com/acm/home?region=us-east-1

### Step 2: Request a public certificate

![request a public certificate](./help-images/cert/request-cert-acm-start.png)

### Step 3: Specify your domain name
![specify your domain name](./help-images/cert/request-cert-step-1.png)

### Step 4: Choose DNS valication
![choose dns validation](./help-images/cert/request-cert-step-2.png)

### Step 5: Add tags (optional)
![optionally add tags](./help-images/cert/request-cert-step-3.png)

### Step 5: Review
![review](./help-images/cert/request-cert-step-4.png)

### Step 6: Pending validation and adding a CNAME at your registrar

At this point, you've gone as far as you can in the AWS console and will be in a state pending validation as shown below:

![pending validation](./help-images/cert/request-cert-step-5.png)

You'll need to use that information with your registrar to add a `CNAME` record so ACM can validate that you own the domain. Here's an example of what this looks like on the registrar we used:

![add a cname](./help-images/cert/request-cert-step-6.png)

### Step 7: Wait for issuance (probably 30-ish minutes)

Now you'll just have to wait for ACM to see the `CNAME` you added and issue the cert. After this happens you should see the status change:

![issued](./help-images/cert/request-cert-step-7.png)

### Step 8: Copy the certificate ARN for use with this CloudFormation stack

![certificate arn](./help-images/cert/request-cert-step-8.png)

## How do I update my domain's nameservers for my PayID domain?

Once you have finished creating the CloudFormation Stack using our template, you'll need to update your nameserver settings on your registrar to use Amazon's. 

### Step 1: View the nameservers in the stack output, or go to Route53 in the AWS console and click on your hosted zone

If you're still on the CloudFormation page looking at the stack, the `Outputs` tab will list the nameservers you need to use.

![stack outputs](./help-images/nameservers/stack-outputs.png)

If you've already closed the tab or navigated away, you can find the same information in Route53.

Link to Route53:
https://console.aws.amazon.com/route53/v2/hostedzones

Once you're on this page, click on the domain you used in the stack template (in this example, `somedomainyouown.com`):

![hosted zones](./help-images/nameservers/hosted-zone-list.png)

### Step 2: Find the nameservers

Clicking on the hosted zone will display the nameservers you need to use with your registrar:

![hosted zone nameservers](./help-images/nameservers/hosted-zone-nameservers.png)

### Step 3: Update your registrar with Amazon's nameservers

Paste the values you saw in the previous step into wherever your registrar allows you to change them. For example:

![registrar nameservers](./help-images/nameservers/registrar-nameservers.png)


## Launching using scripts

Several scripts are provided to make it simple to request a AWS certificate for your payid domain and launch the payid
lambda stack on your domain.
- [request-certificate.sh](request-certificate.sh) - to request a certificate via AWS certificate manager for a given domain.
- [create-stack.sh](create-stack.sh) - to create the PayID lambda stack on your account for a given domain.

### Prequisites

- AWS cli must be installed (see https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- `aws configure` must have been configured with an Access Key created via https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials
- You must have a domain and the ability to configure DNS for your domain. 

### Usage

#### Requesting a certificate

Commamd: `./request-certificate.sh <domain-name>`

Example:
```
$ ./request-certificate.sh hodl.payid.ml

Requesting certificate for hodl.payid.ml
Certificate requested. Please create the following CNAME record for your domain:
_09dee7696e4d458fb16fead080465035.hodl.payid.ml.	CNAME	_b1fddaad4657f8e03167be7b61dc3685.jfrzftwwjs.acm-validations.aws.
```

Once the certificate request is completed, create the CNAME for your domain as specified in the output.

Wait for AWS Certificate Manager to issue your certificate before proceeding to the next command.

#### Launching the PayID Lambda stack

Commamd: `./create-stack.sh <domain-name>`

Example:
```
$ ./create-stack.sh hodl.payid.ml

Creating stack hodl-payid-ml-payid-stack in AWS...

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - hodl-payid-ml-payid-stack

Created successfully
Please update the Nameservers for your domain to
nameserver1	ns-1288.awsdns-33.org
nameserver2	ns-852.awsdns-42.net
nameserver3	ns-1593.awsdns-07.co.uk
nameserver4	ns-8.awsdns-01.com
```

Once completed, update the nameservers for your domain to the ones specified in the output.

