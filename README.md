# Aviatrix SP1 Demo Environment

 This code will deploy a VPC in AWS with 2 Linux workloads running Gatus
 It can also deploy an Aviatrix Spoke gateway for egress if you choose to (default is to deploy). This is to accelerate the demo process.

 Before running, please note the following:

 1. Update the AWS Provider with your credentials information
 2. Update the tfvars file to your required inputs if you choose to use tfvars
 3. You can modify the Gatus config in the vpc1_test_server.tftpl file if you so wish (recommend to use it as is)
 4. If you run without tfvars, you will be prompted for your AWS account name, controller ip and credentials
 5. The code will output the loadbalancer URL for the 2 workloads. It's the same URL with port 80 and port 81



![Paul Aviatrix Template v2 - Page 10](https://github.com/user-attachments/assets/ad1ca413-cf3c-49bf-ae85-2444b0a7b575)


Terraform Variable fields as shown below.

<img width="1548" alt="image" src="https://github.com/user-attachments/assets/0aed649c-3c9e-404f-a5c6-071945bb2c79">

| Variable | Description |
| ------------- | ------------- |
|aviatrix_aws_account_name|the AWS account that's know to the aviatrix co-pilot, name must match with onboarded account|
|aviatrix_controller_ip|Controller IP address that can be gathered after the deployment|
|aviatrix_password|Admin password to login aviatrix platform|
|aviatrix_username|User to login aviatrix platform|
|avx_gateway_size|Gateway EC2 instance size|
|aws_region|Region that the instances will be deployed|
|deploy_aws_egress_gateways|whether to deploy egress gateway or not|
|deploy_aws_workloades|whether to deploy predefined aws workloads or not|
|number_of_azs|how many availability zones that the system will be deployed|
|AWS_ACCESS_KEY_ID|AWS Key id that will be used by Terraform to login to AWS portal, it should be marked as environment variable|
|AWS_SECRET_KEY_ID|AWS Secret id that will be used by Terraform to login to AWS portal, it should be marked as environment variable|
