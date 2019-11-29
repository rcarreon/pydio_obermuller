### Common ###
variable  "ami" 			{ default = "ami-015954d5e5548d13b" }
variable  "type" 			{ default = "t2.micro" }
variable  "key"				{ default = "iac" }
variable  "org"				{ default = "rob" }
variable  "project"			{ default = "iac" }
variable  "tier_app"			{ default = "app" }
variable  "vpc"				{ default = "vpc-db86babc"}
variable  "access_key"		  	{  }
variable  "secret_key"			{  }

variable  "root_pass"			{  }
variable  "pydio_pass"			{  }

### Security group ###
variable  "tier_sg"			{ default = "asg" }
variable  "cidr_all"	                { default = "0.0.0.0/0" }
variable  "cidr_cidr1"			{ default = "177.228.76.208/32" }
variable  "cidr_cidr2"			{ default = "187.189.34.224/32" }

### Loadbalancer ###
variable  "subnet_a"			{ default = "subnet-8857b8ee" }
variable  "tier_lb"			{ default = "lb" }

### s3 ###
variable "acl"			 	{ default = "private" }
variable "bucket"                       { default = "obermuller-bucket"}
variable "env"                          { default = "prod"} 
