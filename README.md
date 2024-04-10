# AWS EC2 Quick 'n Easy

Clone this repo and follow the instructions below to spin up an AWS EC2 t2.micro instance (free tier elligible) with Terraform. It automatically creates an SSH key-pair and the relevant security group settings so that the instance can be accessed via SSH. You'll obviously need to have an AWS account, and you will also need to have installed and configured the AWS CLI so that you are using the correct profile/credentials.  I like to use `envrc` to export and remove environment variables depending on whether I am working in the repo or not. And at the risk of completely overstating the obvious, you do need to have Terraform installed as well. 

Initialise Terraform:

```
terraform init
```

Spin up the instance and take note of the public IP address that AWS assigns to the instance.

```
terraform plan
terraform apply
```

Get the SSH private key:

```
terraform output -raw ssh_private_key >my-private-key
``` 

Set private key file permissions:

```
chmod 400 my-private-key
```

Access the instance via SSH:

```
ssh -i my-private-key ubuntu@<public-ip-address-of-instance>
```

Once you're done, destroy the instance:

```
terraform destroy
```


