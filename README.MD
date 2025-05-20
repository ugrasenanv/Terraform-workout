# AWS VPC Configuration Summary
The Terraform configuration creates an AWS VPC with related resources:

- **VPC:** A VPC with CIDR block 10.0.0.0/16 is created with DNS support and hostnames enabled.
- **Subnets:** Four subnets are created within the VPC - two public and two private. Instances in public subnets are automatically assigned a public IP.
- **Internet Gateway:** An Internet Gateway is created and attached to the VPC, providing internet access to instances.
- **VPC Endpoint:** A VPC endpoint for AWS Systems Manager (SSM) is created, allowing instances to communicate with SSM without needing public internet access.

# AWS Route Table Configuration Summary
The Terraform configuration extends the previously created AWS VPC with route tables and their associations:

- **Public Route Table:** A route table is created for the VPC, with a route directing all traffic (0.0.0.0/0) to the Internet Gateway. This route table is associated with the two public subnets, enabling instances in these subnets to access the internet.

- **Private Route Table:** Another route table is created for the VPC, with a route directing all traffic (0.0.0.0/0) to a NAT Gateway. This route table is associated with the two private subnets, allowing instances in these subnets to access the internet indirectly via the NAT Gateway.


# AWS Application Load Balancer and Related Resources Configuration Summary
The Terraform configuration creates an AWS Application Load Balancer (ALB) and related resources:

- **ALB:** An ALB named "ECS-FastAPI" is created, associated with a security group and deployed in two public subnets.

- **Target Group:** A target group named "ECS-FastAPI-target" is created in the VPC. It listens on port 8000 using HTTP protocol. A health check is configured on the path "/healthcheck".

- **ALB Listener:** A listener is created for the ALB that listens on port 8000 using HTTP protocol. Incoming requests are forwarded to the target group.

- **Launch Template:** A launch template named "machine-aws" is created with specified AMI, instance type, key pair, and security group. It also includes user data for running an Ansible script (ansible.sh) and an IAM instance profile.

- **Key Pair:** A key pair is created with the provided public key.

- **Local File:** A local file is created using a template file and the DNS name of the ALB.

The DNS name of the ALB is output for external access.

ansible.sh
```
Ansible Setup Script Summary
This bash script sets up an environment for running an Ansible playbook on an Ubuntu system. Here's a summary of what it does:

Environment Setup: It updates the system packages, installs necessary dependencies, and sets up logging.

Python and Ansible Installation: It installs Python3, pip, and Ansible.

Directory and File Setup: It creates necessary directories and files, and sets appropriate permissions.

Environment Variables: It sets up environment variables related to AWS.

Ansible Playbook: It creates an Ansible playbook with tasks to:

Install Python3, virtualenv, and AWS CLI.
Retrieve the instance ID.
Install and configure the CloudWatch agent.
Retrieve the SSH key from AWS SSM and set it up for the ubuntu user.
Ensure the /home/ubuntu/tcc directory is owned by ubuntu.
Clone the git repository "project_name-api.git" from Bitbucket.
Install Python packages from requirements.txt in a virtual environment.
Move the .env file to the project directory.
Start the server using uvicorn.
Playbook Execution: It executes the Ansible playbook as the ubuntu user.

Health Check: It performs a health check by making a request to http://localhost:8000/healthcheck until it gets a response.

Lifecycle Action Completion: It completes the lifecycle action for the AWS Auto Scaling group.
```

# AWS Auto Scaling Group and Related Resources Configuration Summary
The Terraform configuration creates an AWS Auto Scaling Group (ASG) and related resources:

- **ASG:** An ASG named as per the variable groupName is created. It is associated with two private subnets and uses the previously created launch template. It is also associated with the target group of the ALB. The desired, maximum, and minimum capacities are set as per the variables.

- **Auto Scaling Schedules:** Two auto scaling schedules named "development-up" and "development-down" are created. They adjust the ASG's capacity based on the time of day, increasing capacity during working hours and decreasing it outside of working hours.

- **Auto Scaling Policies:** Three auto scaling policies are created. The "target_tracking_policy" adjusts the number of instances in the ASG to maintain an average CPU utilization of 60%. The "scaling_policy_up" and "scaling_policy_down" policies increase and decrease the number of instances in the ASG by 2 and 1 respectively.

- **Lifecycle Hook:** A lifecycle hook named "lifecycle-hook" is created for the ASG. It is triggered when an instance is launching and continues the launch process if no action is taken within 450 seconds.


# AWS CloudWatch Alarms Configuration Summary
The Terraform configuration creates several AWS CloudWatch alarms to monitor the system's performance and health:

- **CPU High Alarm:** An alarm named "cpu_high" is created. It triggers when the CPU utilization exceeds 60% for three consecutive periods of 30 seconds. The alarm action is to execute the "scaling_policy_up" auto scaling policy and send a notification to the "lambda_update_instance" SNS topic.

- **CPU Low Alarm:** An alarm named "cpu_low" is created. It triggers when the CPU utilization is below 55% for two consecutive periods of 60 seconds. The alarm action is to execute the "scaling_policy_down" auto scaling policy.

- **High Response Time Alarm:** An alarm named "high_response_time" is created. It triggers when the target response time exceeds 5 seconds (or your desired threshold) for three consecutive periods of 180 seconds. The alarm action is to send a notification to the "alarm" SNS topic.

- **Status Check Failed Alarm:** An alarm named "status_check_failed" is created. It triggers when the status check fails three times in a row over a period of 180 seconds. The alarm action is to send a notification to the "alarm" SNS topic.

- **Unhealthy Hosts Alarm:** An alarm named "unhealthy_hosts" is created. It triggers when the number of unhealthy hosts exceeds 2 (or your desired threshold) for two consecutive periods of 60 seconds. The alarm action is to send a notification to the "alarm" SNS topic.

All alarms are tagged with the client name "client_name" and the project name "quiz".

# AWS SNS Topics and Subscriptions Configuration Summary
The Terraform configuration creates two AWS Simple Notification Service (SNS) topics and their corresponding subscriptions:

- **Alarm Topic:** An SNS topic named "alarm-topic" is created. A subscription is also created for this topic with the protocol set to "email" and the endpoint set to "victor.almeida@company.com". This means that when a message is published to this topic, an email will be sent to the specified email address.

- **Lambda Update Instance Topic:** Another SNS topic named "alarm-update-instance" is created. A subscription is also created for this topic with the protocol set to "lambda" and the endpoint set to the ARN of a specific AWS Lambda function. This means that when a message is published to this topic, the specified Lambda function will be triggered.



# AWS Security Group and Instance Configuration Summary
The Terraform configuration creates an AWS security group, security group rules, and an EC2 instance with related resources:

- **Security Group:** A security group named "public_instance_sg" is created for the VPC. It allows all outbound traffic.

- **Security Group Rules:** Nine ingress rules are created for the security group. They allow incoming traffic on ports 22, 80, 443, 5555, 5432, and 8000 from specific CIDR blocks. The descriptions and CIDR blocks for each rule vary.

- **IAM Role:** An IAM role named "s3_access_role" is created. It allows EC2 instances to assume the role.

- **IAM Instance Profile:** An IAM instance profile named "s3_access_profile" is associated with the "s3_access_role".

- **EC2 Instance:** An EC2 instance of type "t4g.small" is created in the second public subnet. It uses a specific AMI and key pair. It is associated with the security group and the IAM instance profile. User data is provided to the instance via a template file, with various variables passed in. The instance is also tagged with the client name "client_name", the project name "quiz", and the name "Public Instance" and uses "main_application.sh" to set up the application.

- **EIP Association:** An Elastic IP address is associated with the EC2 instance.

The security group and its rules, along with the EC2 instance, extend the previously created VPC, subnets, and route tables. They provide the necessary security measures and compute resources for the application.

main_application.sh
```
## Main Application Setup Script Documentation
The main_application.sh script is a Bash script used to set up an application environment on an Ubuntu server. Here's a breakdown of what it does:

1. **Environment Setup**
The script starts by updating the system's package list and installing necessary packages. These include build tools, Python3 and its pip package manager, PostgreSQL development libraries, Nginx, Celery, Django Celery Beat, and RabbitMQ server.

2. **Certbot Installation**
Certbot is installed for managing SSL certificates. It's installed using the snap package manager and a symbolic link is created to make it accessible from the system path.

3. **Python Pip Installation**
The script downloads and runs the get-pip.py script to install pip for Python3.

4. **Ansible Installation**
Ansible is installed using pip. Ansible is an IT automation tool that can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

5. **Directory and File Setup**
Several directories and files are created and their ownership is set to the ubuntu user. These include directories for logs, Gunicorn, Nginx, and static files for the Django application. An SSH key file is also created.

6. **Environment Variables**
Environment variables are set by appending them to the .env file in the ubuntu user's home directory. These variables include AWS credentials, database credentials, Django settings, and others.

7. **PostgreSQL Backup Script**
A PostgreSQL backup script is created which dumps the database to a file and then uploads it to an S3 bucket.

8. **Static Files Collection Script**
A script is created to collect static files for the Django application and invalidate the CloudFront distribution.

9. **Ansible Playbook**
An Ansible playbook is created to automate the setup of the application. This includes tasks such as installing necessary packages, setting up SSH keys, cloning the application repository, setting up the virtual environment, setting up the database, configuring Nginx, setting up SSL, and starting the application.

10. **Running the Playbook**
Finally, the Ansible playbook is run as the ubuntu user.

This script is intended to be run on a fresh Ubuntu server to set up the application environment. It should be run with root privileges.
```

# AWS Bastion Host Configuration Summary
The Terraform configuration extends the previously created AWS VPC with a bastion host and its associated security group:

- **Bastion Security Group** A security group named "bastion" is created for the VPC. It allows SSH inbound traffic from any IP address (0.0.0.0/0). All outbound traffic is also allowed.

- **Bastion Host:** An EC2 instance named "Bastion Host" is created. It uses a specific AMI and instance type (t2.nano). The instance is associated with the "bastion" security group and deployed in the first public subnet. It is also associated with a specific key pair for SSH access. The instance is configured to automatically associate a public IP address. A script named "terminate_instance.sh" is provided as user data to the instance, which is executed upon instance launch.

The bastion host provides a secure, controlled access point to the private resources within the VPC. It extends the VPC's security by limiting SSH access to a single point that can be closely monitored and controlled.

# AWS IAM Configuration Summary
The Terraform configuration creates an AWS IAM role, policies, and an instance profile:

- **IAM Role: An IAM role named "ec2_ssm" is created. This role can be assumed by EC2 and Lambda services.

- **IAM Policies: Three IAM policies are created:

    - *"ssm_s3_rekognition"*: Allows EC2 instances to access SSM Parameter Store, S3, Rekognition, Auto Scaling groups, EC2 instances, network interfaces, and CloudWatch.
    - *"CloudWatchPutMetricData"*: Allows EC2 instances to put metric data to CloudWatch.
    - *"cloudfront_s3_access"*: Allows access to CloudFront distributions and S3 objects.
    - *IAM Role Policy Attachments*: The policies are attached to the "ec2_ssm" role.

- **IAM Instance Profile:** An IAM instance profile named "instance_profile" is created and associated with the "ec2_ssm" role.

This configuration allows EC2 instances to access various AWS services, including SSM, S3, Rekognition, CloudFront, and CloudWatch. It also allows instances to put metric data to CloudWatch and manage network interfaces. The instance profile can be associated with EC2 instances to grant them the permissions defined in the role.


# AWS CloudFront Configuration Summary
The Terraform configuration creates an AWS CloudFront distribution and an origin access identity:

- **CloudFront Distribution:** A CloudFront distribution named "s3_distribution" is created with two origins:

    - *"S3Origin"*: Configured to access the specified S3 bucket using the origin access identity.
    - *"EC2Origin"*: A custom origin configured to use HTTPS only with TLSv1.1 and TLSv1.2.
The distribution is enabled and supports IPv6. The default root object is set to "main.html". It has three cache behaviors:

    - Default cache behavior: Allows all HTTP methods and caches GET and HEAD requests. It targets the "EC2Origin" and does not forward query strings or cookies.
    - Ordered cache behavior for "/static/*" path: Allows and caches GET and HEAD requests. It targets the "S3Origin" and does not forward query strings or cookies.
    - Ordered cache behavior for "/media/" path: Similar to the "/static/" path behavior but for "/media/*" path.
The distribution uses the default CloudFront certificate and does not have any geo restrictions. It is tagged with the client and project information.

- **CloudFront Origin Access Identity:** An origin access identity (OAI) is created for the S3 bucket. This allows the CloudFront distribution to fetch objects from the S3 bucket while keeping the objects private from direct access.

- **Output:** The ID of the CloudFront distribution is outputted for use in other resources or outputs.

This configuration sets up a CloudFront distribution to serve static and media content from an S3 bucket and other content from an EC2 instance, with caching and HTTPS enforced.



# Documentation: project_name Project AWS Architecture Overview
This document provides an overview of the AWS architecture implemented for the project_name project. The architecture is designed to support a robust, secure, and scalable web application, with a specific focus on handling resource-intensive background removal tasks efficiently and reliably.

## Introduction
In the project_name project, we have implemented a comprehensive and robust AWS architecture designed to support a highly scalable, secure, and efficient web application. This architecture leverages a variety of AWS services, each playing a crucial role in ensuring optimal performance and reliability.

The core of our architecture is the AWS Virtual Private Cloud (VPC), configured with a 10.0.0.0/16 CIDR block, enabling DNS support and hostnames. Within this VPC, we have established four subnets: two public and two private, facilitating effective network segmentation and resource access control.

## Key components of our architecture include:

- AWS Application Load Balancer (ALB): Positioned in the public subnets, the ALB acts as the entry point for web traffic, distributing it across EC2 instances to ensure load balancing and high availability.
- AWS Auto Scaling Group (ASG): Deployed in private subnets, the ASG dynamically adjusts EC2 instances based on load, specifically handling the resource-intensive background removal function.
- AWS Route Tables: These include a Public Route Table for direct internet access via the Internet Gateway and a Private Route Table for controlled internet access through a NAT Gateway, essential for secure operations and updates.
- AWS CloudFront: This content delivery network optimizes the delivery of static and dynamic web content, working in conjunction with S3 buckets for storage and distribution efficiency.
- AWS Simple Notification Service (SNS): Facilitates communication and automated responses for system events, enhancing operational responsiveness.
- AWS CloudWatch: Monitors the system, collecting and tracking metrics and logs, and setting alarms to ensure performance and health.
- AWS S3 Bucket: Provides durable and scalable storage for application data, backups, and static content, crucial for data management and content delivery.

This architecture not only supports the main application deployed on public instances but also efficiently manages the background removal function, a resource-intensive task, by isolating it in the private subnet. This separation ensures that spikes in traffic or demand do not compromise the overall application performance. The integration of these AWS services within the VPC framework provides a secure, reliable, and scalable environment, essential for the success of the project_name project.

## AWS Route Table Configuration
**Overview**
The AWS Route Table configuration in the project_name project is a key component ensuring that different resources within the VPC have appropriate access to the internet, depending on their role and security requirements. This configuration includes a Public Route Table and a Private Route Table, each serving distinct purposes in the network infrastructure.

Public Route Table Configuration
- **Function:** The Public Route Table is associated with the public subnets. Its primary role is to facilitate direct internet access for resources within these subnets.
- **Internet Gateway Connection:** It includes a route that directs all outbound traffic (0.0.0.0/0) to the Internet Gateway. This setup allows EC2 instances in the public subnets to directly access the internet, which is essential for tasks like sending responses to client requests and accessing public AWS services.
- **Use Case:** The Public Route Table is especially crucial for the public_instance deployed in these subnets, hosting the main application. It enables this instance to communicate effectively with external users and services.

Private Route Table Configuration
- **Function:** The Private Route Table is associated with the private subnets of the VPC. Its primary function is to provide controlled internet access to resources in these subnets, which do not have direct internet connectivity.
- **NAT Gateway Connectivity:** This route table contains a route that directs all outbound traffic (0.0.0.0/0) to a NAT (Network Address Translation) Gateway. The NAT Gateway acts as an intermediary, enabling instances in the private subnet to access the internet for specific tasks while keeping them isolated from direct inbound internet connections.
- **Enhanced Security:** This configuration enhances security by reducing the exposure of sensitive components, like the instances handling the background removal function, to the public internet.
- **Essential for Code Deployment and Updates:** Instances in the private subnet need to access the internet to download the application code from Bitbucket and install necessary libraries for the background removal application to run. The Private Route Table configuration ensures that these instances can securely reach out to Bitbucket and other external resources to fetch updates, patches, or additional dependencies required for their operation.
- **Reliability in Resource-Intensive Operations:** By isolating the background removal function in the private subnet and providing indirect internet access, the architecture ensures that this resource-intensive operation does not directly impact the main application's performance and availability. This separation is crucial for maintaining overall system reliability, especially during high-traffic periods or when scaling up resources in response to increased demand.

Conclusion
In summary, the Route Table configuration in the project_name project plays a pivotal role in balancing the security and operational requirements of the system. The Public Route Table facilitates direct internet access for user-facing services, while the Private Route Table offers a secure pathway for backend operations to access external resources without exposing them to the open internet. This setup is instrumental in maintaining the application's integrity, performance, and security.


## AWS IAM Configuration
The AWS Identity and Access Management (IAM) configuration in the project_name project is a crucial aspect of ensuring secure and efficient access to various AWS services. This setup involves creating IAM roles and policies, allowing precise control over the permissions granted to AWS resources and services.

### IAM Role and Policy Configuration
1. IAM Role: ec2_ssm
- **Purpose:** This role is created for EC2 and Lambda services to interact with other AWS services under specific permissions.
- **Trust Relationship:** Defined to allow ec2.amazonaws.com and lambda.amazonaws.com to assume this role, indicating that EC2 instances and Lambda functions can adopt the permissions associated with this role.

2. IAM Policies
- **ssm_s3_rekognition Policy:** Grants permissions to EC2 instances for accessing SSM Parameter Store, S3, Rekognition, Auto Scaling groups, EC2 instances, network interfaces, and CloudWatch. This policy is integral for allowing instances to retrieve parameters, store and retrieve data from S3, utilize Rekognition services, and interact with other EC2 and networking features.
- **CloudWatchPutMetricData Policy:** Specifically allows EC2 instances to put metric data into CloudWatch. This is important for monitoring the performance of the instances and the applications running on them.
- **cloudfront_s3_access Policy:** Grants access to CloudFront distributions and S3 objects. This policy is essential for managing CloudFront distributions and accessing data stored in S3 buckets.

3. IAM Role Policy Attachments
- Attachments are made between the ec2_ssm role and the policies cloudfront_s3_access, ssm_s3_rekognition, and cloudwatch. These attachments ensure that the EC2 instances and Lambda functions assuming the ec2_ssm role have the necessary permissions to perform their designated tasks.

4. IAM Instance Profile
- An IAM instance profile named instance_profile is created and associated with the ec2_ssm role. This profile is attached to EC2 instances, enabling them to inherit the permissions specified in the ec2_ssm role.

#### Conclusion
The IAM configuration in the project_name project plays a pivotal role in managing access and permissions across various AWS services. By creating specific roles and policies, and associating them with relevant AWS resources, the project ensures a secure and controlled environment. This approach not only enhances security by following the principle of least privilege but also streamlines the interaction between different AWS services, contributing to the overall efficiency and reliability of the application infrastructure.

## S3 Bucket Configuration
In the project_name project, the AWS S3 bucket plays a critical role in storing and managing media and static files for the quiz application, as well as holding the keys used for setting up both the main and background removal applications. The configuration of this S3 bucket, `project_name-quiz-company`, is established through Terraform scripts to ensure secure, efficient, and organized access to these resources.

#### S3 Bucket Usage
- **Media and Static Files Storage:** The bucket stores media files (like images and videos) and static files (like CSS, JavaScript, and HTML files) required for the quiz application. These files are crucial for the application's user interface and overall user experience.
- **Key Storage:** It also holds keys necessary for the setup and operation of the main application and the background removal function. These keys might include SSH keys, API keys, or other configuration files.

#### S3 Bucket Policy Configuration
- **Bucket Policy:** The policy defined in the Terraform script is tailored to meet specific access requirements:
  - **IAM Role Access (Sid: AllowIAMRoleAccess):** Grants the `s3_access_role` permissions to put, get, and delete objects within the `keys/` directory of the bucket. This is essential for the EC2 instances to access configuration keys securely.
  - **Public Read Access (Sid: PublicReadAccessMedia and PublicReadGetObject):** Allows public read access to the `media/` and `static/` directories. This is crucial for serving media and static content to the application users without requiring authentication.
  - **EC2 Instance Access (Sid: AllowAccessFromEC2Instance):** Provides broader permissions for the `s3_access_role` associated with EC2 instances, enabling them to access and manipulate objects in the `static/`, `project_name-quiz.js`, and `keys/` directories.

#### Conclusion
The configuration of the AWS S3 bucket `project_name-quiz-company` is a vital component of the project_name project's AWS architecture. By utilizing Terraform for infrastructure as code, we have established a secure, efficient, and highly functional storage solution. This setup not only supports the operational needs of the quiz application but also adheres to best practices for AWS resource management and security. The defined bucket policy ensures that the application has the necessary access to its static and media content, while also maintaining the confidentiality and integrity of key configuration files. 

## Main Application Setup
### AWS EC2 Instance Configuration (Terraform and Ansible)
The EC2 instance, named public_instance, plays a crucial role in hosting the main application for the project_name project. It is finely tuned through a combination of Terraform and Ansible scripts to ensure optimal performance and security.

- **Terraform Configuration:**
    - **Instance Details:** Utilizes the t4g.small instance type and is associated with the public_instance_sg security group and a specific subnet for network placement.
    - **Public IP Assignment:** The instance is configured with a public IP address for external accessibility.
    - **IAM Role Integration:** Linked with the s3_access_role IAM role, granting necessary permissions for AWS service interactions.
    - **User Data Provisioning:** Uses the main_application.sh script to feed environment-specific variables and configurations.

- **Ansible Configuration (main_application.sh):**
    - **System and Software Setup:** Involves updating system packages and installing essential software like Python3, pip, Nginx, Celery, and related tools.
    - **Environment Configuration:** Sets up critical environment variables for AWS services, database connections, and Django application settings.
    - **Security and Repository Setup:** Manages SSH keys for secure access, adds Bitbucket to known hosts for Git operations, and clones the application code from the repository.
    - **Application and Database Configuration:** Covers Python package installation, PostgreSQL setup, Nginx configuration, and SSL certificate management.
    - **Backup and Static File Management:** Scripts for handling PostgreSQL backups to S3 and managing Django static files are included.
    - **Ansible Playbook:** Automates the entire setup process, ensuring that the web server and database are properly configured and the application is ready for deployment.

### AWS Security Group Configuration
The security group, public_instance_sg, is essential for defining and enforcing the network security rules for the application.

- **Ingress Rules:**
    - **SSH Access (port 22):** Specific rules like rule_1, rule_4, rule_5, and rule_6 permit SSH access from predetermined IP addresses.
    - **Web Traffic (port 80 and port 443):** Rules rule_2, rule_3, and rule_7 enable HTTP and HTTPS traffic, fundamental for web application accessibility.
    - **Application-Specific Traffic:** Rules rule_8, rule_9, and allow_http_8000 allow traffic on custom application ports like 5555, 5432, and 8000.
    - **Security Consideration:** Rule rule_5 permits unrestricted SSH access, which might need to be revisited for tighter security.

- Egress Rules:
    - **Outbound Traffic:** The configuration allows all outbound traffic, enabling the instances to communicate with external services for updates and integrations.

#### Conclusion
In the project_name project, the EC2 instance configuration is meticulously crafted using Terraform and Ansible to host the main application, ensuring it is secure, efficient, and fully functional. The security group public_instance_sg complements this setup by enforcing strict network access rules, aligning with the project's security requirements. This approach showcases a strategic use of infrastructure as code practices, leveraging the strengths of AWS for a secure and scalable application environment.

## AWS CloudFront Configuration for the project_name Project
In the project_name project, AWS CloudFront plays a significant role in delivering media and static files for the main application. The CloudFront distribution is configured to serve content from both an S3 bucket and an EC2 instance, ensuring efficient and fast delivery of web content to users.

### CloudFront Distribution Configuration
1. **Distribution Setup:**
- Enabled and IPv6 Support: The distribution is enabled and configured to support IPv6, aligning with modern internet standards.
- Comment and Default Root Object: Includes a descriptive comment and specifies main.html as the default root object.
- Price Class: Set to PriceClass_100, which is the most cost-effective option. It uses a limited set of AWS edge locations, focusing mainly on North America and Europe.

2. **Origins Configuration:**
- S3 Origin: Configured to use the S3 bucket project_name-quiz-company.s3.eu-west-2.amazonaws.com as one of its origins, with an Origin Access Identity (OAI) for secure access.
- EC2 Origin: Another origin points to an EC2 instance, with custom settings for HTTP and HTTPS ports and protocols, ensuring that the content is served securely using https-only policy.

3. **Cache Behaviors:**
- **Default Cache Behavior:** Configured to handle various HTTP methods, targeting the EC2Origin. It includes settings for cookies, query strings, and TTL values.
- **Ordered Cache Behaviors:**
    - *Static Files*: For the path pattern /static/*, pointing to the S3Origin. It allows only GET and HEAD requests, optimizing the caching of static assets.
    - *Media Files*: Similar to static files, but for the path pattern /media/*. This setup is crucial for efficiently serving media content from the S3 bucket.

4. **Viewer Certificate:**
- Uses the default CloudFront certificate to handle SSL/TLS traffic, ensuring secure delivery of content.

5. **Restrictions:**
- Geo Restriction: Set to none, allowing the distribution to serve content globally without restrictions.

6. **Tags:**
- Includes tags for client (client_name) and project (quiz), aiding in resource management and billing.

#### Conclusion
The AWS CloudFront configuration in the project_name project is a key component in ensuring efficient delivery of static and media content. By leveraging CloudFront's global network, the project significantly improves load times and user experience while maintaining security and cost-effectiveness. This setup underscores the project's commitment to leveraging advanced AWS services to enhance the performance and scalability of the web application.

## Background Removal Setup
The background removal functionality is a resource-intensive task which required a dedicated and scalable AWS setup. This setup includes an AWS Application Load Balancer (ALB), an Auto Scaling Group (ASG), and a customized launch template, all orchestrated through Terraform and Ansible scripts.

### AWS Application Load Balancer (ALB) Configuration
- **ALB Creation:** An ALB named "ECS-FastAPI" is created to manage incoming traffic from the main application.
- **Security and Network:** The ALB is associated with security groups and deployed across public subnets, ensuring high availability and security.
- **Functionality:** It is responsible for distributing incoming traffic, from the main application, across multiple EC2 instances, which are part of the Auto Scaling Group. This setup helps in efficiently managing the load and ensures high availability of the background removal service, while also maintaining security and keeping the instances isolated from the internet.

### AWS Auto Scaling Group (ASG) Configuration
- **ASG Setup:** An Auto Scaling Group named "IaC-Prod" is configured to scale EC2 instances in and out based on demand.
- **Subnet Association:** The ASG is associated with private subnets, ensuring that the background removal tasks are performed securely without direct exposure to the internet.
- **Scaling PoliciesO:** Includes policies for scaling up and down based on CPU utilization. This dynamic scaling is critical for handling varying loads efficiently.
- **Health Checks:** Utilizes ELB health checks to ensure that the instances in the ASG are healthy and functioning as expected.


### AWS Launch Template Configuration
- **Launch Template Creation:** A launch template named "machine-aws" is defined to specify the configuration of EC2 instances launched in the ASG.
- **Instance Specifications:** Includes settings like AMI, instance type, key name, and security groups.
- **User Data:** Incorporates the ansible.sh script, which is executed when new instances are launched. This script sets up the environment required for the background removal application to run.

#### Ansible Script (ansible.sh)
- **Initial Setup:** Updates system packages and installs necessary software like Python3, pip, and dependencies required for background removal tasks.
- **Environment Configuration:** Sets up environment variables needed for AWS services and application configuration.
- **Application Setup:** Includes steps to clone the application code from the Bitbucket repository, install Python packages, and start the background removal service using uvicorn.
- **Health Check:** Incorporates a health check to ensure the application is running correctly before signaling the ASG that the instance is ready.

### AWS Auto Scaling Lifecycle Hook
- **Lifecycle Hook:** A lifecycle hook named "lifecycle-hook" is configured for the ASG to manage the instance initialization process. This ensures that new instances are fully operational before they start receiving traffic.

#### Conclusion
The background removal setup in the project_name project is designed to provide a scalable, secure, and efficient environment for processing resource

## AWS CloudWatch and SNS Configuration
The project_name project incorporates AWS CloudWatch and Simple Notification Service (SNS) for effective monitoring and alerting. CloudWatch Alarms are set up to monitor various metrics, and AWS SNS topics are configured to send notifications or trigger actions based on these alarms.

### AWS CloudWatch Metric Alarms Configuration
1. **CPU High Alarm (cpu_high):**
- **Function:** Monitors CPU utilization of the EC2 instances in the Auto Scaling Group.
- **Alarm Condition:** Triggers when CPU utilization is greater than or equal to 60% for three consecutive periods of 30 seconds.
- **Actions:** Executes scaling_policy_up and sends a notification to lambda_update_instance SNS topic upon alarm.

2. **CPU Low Alarm (cpu_low):**
- **Function:** Ensures efficient scaling by monitoring low CPU utilization.
- **Alarm Condition:** Triggers when CPU utilization is below 55% for two consecutive periods of 60 seconds.
- **Actions:** Executes scaling_policy_down upon alarm.

3. **High Response Time Alarm (high_response_time):**
- **Function:** Monitors the response time of the targets in the target group.
- **Alarm Condition:** Triggers when the target response time exceeds 5 seconds (or a set threshold) for three consecutive periods of 180 seconds.
- **Actions:** Sends a notification to alarm SNS topic upon alarm.

4. **Status Check Failed Alarm (status_check_failed):**
- **Function:** Monitors the health of the EC2 instances in the Auto Scaling Group.
- **Alarm Condition:** Triggers when the status check fails three times in a row over a period of 180 seconds.
- **Actions:** Sends a notification to alarm SNS topic upon alarm.

5. **Unhealthy Hosts Alarm (unhealthy_hosts):**
- **Function:** Monitors the health of the hosts in the target group.
- **Alarm Condition:** Triggers when the number of unhealthy hosts exceeds 2 (or a set threshold) for two consecutive periods of 60 seconds.
- **Actions:** Sends a notification to alarm SNS topic upon alarm.

### AWS Simple Notification Service (SNS) Configuration
1. **Alarm Topic (alarm-topic):**
- **Purpose:** Serves as a notification channel for various CloudWatch alarms.
- **Subscription (email_subscription):** Configured to send email notifications to victor.almeida@company.com.

2. **Lambda Update Instance Topic (alarm-update-instance):**
- **Purpose:** Used to trigger a specific AWS Lambda function based on certain alarms.
- **Subscription (lambda_update_instance):** Set up to invoke an AWS Lambda function identified by its ARN arn:aws:lambda:eu-west-2:357643864089:function:nbg.

Conclusion
The integration of AWS CloudWatch and SNS in the project_name project enhances its monitoring and alerting capabilities. CloudWatch Alarms ensure real-time monitoring of critical metrics, enabling the system to respond automatically to various performance and health indicators. Concurrently, AWS SNS facilitates prompt notifications and actions, allowing for quick responses to potential issues. This combination of services bolsters the reliability and efficiency of the application, ensuring that it remains robust under varying loads and conditions.



AWS CloudWatch Alarms
Monitors system health and performance, triggering actions based on defined metrics like CPU utilization and response times.
AWS SNS Topics and Subscriptions
Facilitates notifications and automated responses to system events, integrating with Lambda for dynamic response to scaling events.



Security and Reliability
Security Measures
Segmentation: VPC and subnet design segregate resources, limiting exposure and risk.
Access Control: Security groups, IAM roles, and policies tightly control access to AWS resources.
Encryption and Certificates: Use of HTTPS and SSL certificates ensures secure data transmission.
Reliability and Performance
Load Balancing: The ALB efficiently distributes traffic, enhancing application availability and reliability.
Auto Scaling: ASG dynamically adjusts resources to meet demand, ensuring consistent performance.
Health Checks and Monitoring: Continuous monitoring and health checks enable quick detection and response to issues.
Risk Mitigation
Lambda Function: Temporarily restricts access to the resource-intensive background removal function during scaling events, mitigating the risk of overloading.
Lifecycle Hooks: Ensure new instances are fully operational before accepting traffic, reducing the risk of service disruption.
Conclusion
The AWS architecture for the project_name project is designed to deliver a secure, reliable, and scalable solution, particularly adept at handling resource-intensive tasks like background removal. The implementation of various AWS services, including VPC, ALB, ASG, CloudWatch, SNS, IAM, and CloudFront, provides a robust foundation for the application, ensuring optimal performance and security.