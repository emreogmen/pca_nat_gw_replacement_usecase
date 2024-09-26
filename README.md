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
