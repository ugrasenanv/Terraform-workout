# AWS Architecture Overview for project_name Project

This document provides a comprehensive overview of the AWS architecture implemented for the `project_name` project, focusing on creating a robust, secure, and scalable web application that efficiently handles resource-intensive background removal tasks.

## Introduction

The `project_name` project leverages a diverse set of AWS services to ensure optimal performance, reliability, and security for its web application. The architecture is built around an AWS Virtual Private Cloud (VPC) with a 10.0.0.0/16 CIDR block, enabling DNS support and hostnames. Within this VPC, network segmentation is achieved through two public and two private subnets.

Key architectural components include:

* **AWS Virtual Private Cloud (VPC)**: The foundational network for all AWS resources, providing isolation and control.
* **AWS Application Load Balancer (ALB)**: Distributes incoming web traffic across EC2 instances for high availability and load balancing.
* **AWS Auto Scaling Group (ASG)**: Dynamically adjusts EC2 instance capacity to handle varying loads, particularly for the background removal function.
* **AWS Route Tables**: Manages network traffic flow within the VPC, with separate tables for public and private subnets.
* **AWS CloudFront**: A Content Delivery Network (CDN) that optimizes the delivery of static and dynamic web content.
* **AWS Simple Notification Service (SNS)**: Facilitates communication and automated responses for system events.
* **AWS CloudWatch**: Monitors system performance, collects metrics and logs, and triggers alarms.
* **AWS S3 Bucket**: Provides durable and scalable storage for application data, backups, and static content.

This architecture effectively isolates the resource-intensive background removal function in a private subnet to prevent performance impacts on the main application during peak demand.

---

## AWS VPC Configuration

The Terraform configuration establishes the core network infrastructure within AWS.

* **VPC**: A VPC with CIDR block `10.0.0.0/16` is created with DNS support and hostnames enabled.
* **Subnets**: Four subnets are created: two public and two private. Instances in public subnets are automatically assigned a public IP.
* **Internet Gateway**: An Internet Gateway is created and attached to the VPC, providing internet access to instances.
* **VPC Endpoint**: A VPC endpoint for AWS Systems Manager (SSM) is created, allowing instances to communicate with SSM without needing public internet access.

---

## AWS Route Table Configuration

The network traffic within the VPC is managed by distinct route tables for public and private subnets.

* **Public Route Table**:
    * **Function**: Associated with public subnets, enabling direct internet access for resources within them.
    * **Internet Gateway Connection**: Directs all outbound traffic (`0.0.0.0/0`) to the Internet Gateway.
    * **Use Case**: Crucial for the `public_instance` hosting the main application, enabling communication with external users and services.
    
* **Private Route Table**:
    * **Function**: Associated with private subnets, providing controlled internet access to resources without direct public exposure.
    * **NAT Gateway Connectivity**: Directs all outbound traffic (`0.0.0.0/0`) to a NAT Gateway. This allows instances in the private subnet to access the internet for updates and code downloads while remaining isolated from direct inbound connections.
    * **Enhanced Security**: Reduces exposure of sensitive components, such as instances handling the background removal function.
    * **Essential for Code Deployment and Updates**: Enables instances in the private subnet to securely download application code from Bitbucket and install necessary libraries.

---

## AWS Application Load Balancer and Related Resources Configuration

The Terraform configuration sets up an AWS Application Load Balancer (ALB) and its associated components for the `project_name` project.

* **ALB**: An ALB named "ECS-FastAPI" is created, associated with a security group, and deployed in two public subnets. It distributes incoming traffic from the main application across multiple EC2 instances in the Auto Scaling Group.
* **Target Group**: A target group named "ECS-FastAPI-target" is created in the VPC, listening on port 8000 using HTTP. It includes a health check on the path "/healthcheck".
* **ALB Listener**: A listener for the ALB is configured to listen on port 8000 using HTTP, forwarding incoming requests to the target group.
* **Launch Template**: A launch template named "machine-aws" is created with a specified AMI, instance type, key pair, and security group. It also includes user data for running an Ansible script (`ansible.sh`) and an IAM instance profile.
* **Key Pair**: A key pair is created with the provided public key.
* **Local File**: A local file is created using a template and the DNS name of the ALB.
* The DNS name of the ALB is output for external access.

---

## AWS Auto Scaling Group and Related Resources Configuration

The Terraform configuration creates an AWS Auto Scaling Group (ASG) and its related resources for dynamic scaling.

* **ASG**: An ASG named as per the variable `groupName` is created, associated with two private subnets and the previously created launch template. It is also linked to the ALB's target group. Desired, maximum, and minimum capacities are set via variables.
* **Auto Scaling Schedules**: Two schedules, "development-up" and "development-down," are created to adjust ASG capacity during and outside working hours.
* **Auto Scaling Policies**:
    * `target_tracking_policy`: Adjusts instance count to maintain 60% average CPU utilization.
    * `scaling_policy_up`: Increases instance count by 2.
    * `scaling_policy_down`: Decreases instance count by 1.
* **Lifecycle Hook**: A lifecycle hook named "lifecycle-hook" is created for the ASG. It is triggered when an instance is launching and continues the launch process if no action is taken within 450 seconds.

---

## AWS CloudWatch Alarms Configuration

The Terraform configuration sets up several AWS CloudWatch alarms for monitoring system performance and health.

* **CPU High Alarm**: Named "cpu_high," it triggers when CPU utilization exceeds 60% for three consecutive 30-second periods. Actions include executing `scaling_policy_up` and sending a notification to the `lambda_update_instance` SNS topic.
* **CPU Low Alarm**: Named "cpu_low," it triggers when CPU utilization is below 55% for two consecutive 60-second periods. The action is to execute `scaling_policy_down`.
* **High Response Time Alarm**: Named "high_response_time," it triggers when target response time exceeds 5 seconds for three consecutive 180-second periods. The action is to send a notification to the "alarm" SNS topic.
* **Status Check Failed Alarm**: Named "status_check_failed," it triggers when the status check fails three times in a row over 180 seconds. The action is to send a notification to the "alarm" SNS topic.
* **Unhealthy Hosts Alarm**: Named "unhealthy_hosts," it triggers when the number of unhealthy hosts exceeds 2 for two consecutive 60-second periods. The action is to send a notification to the "alarm" SNS topic.
* All alarms are tagged with "client_name" and "quiz" for project identification.

---

## AWS SNS Topics and Subscriptions Configuration

The Terraform configuration creates two AWS Simple Notification Service (SNS) topics and their corresponding subscriptions.

* **Alarm Topic**:
    * An SNS topic named "alarm-topic" is created.
    * A subscription is created for this topic with the protocol "email" and the endpoint "victor.almeida@company.com".
* **Lambda Update Instance Topic**:
    * Another SNS topic named "alarm-update-instance" is created.
    * A subscription is created for this topic with the protocol "lambda" and the endpoint set to the ARN of a specific AWS Lambda function (`arn:aws:lambda:eu-west-2:357643864089:function:nbg`).

---

## AWS Security Group and Instance Configuration

The Terraform configuration defines an AWS security group, security group rules, and an EC2 instance.

* **Security Group**: A security group named "public_instance_sg" is created for the VPC, allowing all outbound traffic.
* **Security Group Rules**: Nine ingress rules are created for the security group, allowing incoming traffic on ports 22, 80, 443, 5555, 5432, and 8000 from specific CIDR blocks.
* **IAM Role**: An IAM role named "s3_access_role" is created, allowing EC2 instances to assume the role.
* **IAM Instance Profile**: An IAM instance profile named "s3_access_profile" is associated with the `s3_access_role`.
* **EC2 Instance**: An EC2 instance of type "t4g.small" is created in the second public subnet. It uses a specific AMI and key pair, and is associated with the security group and IAM instance profile. User data is provided via a template file with various variables. The instance is tagged with "client_name," "quiz," and "Public Instance," and uses `main_application.sh` for application setup.
* **EIP Association**: An Elastic IP address is associated with the EC2 instance.

---

## AWS Bastion Host Configuration

The Terraform configuration extends the VPC with a bastion host for secure access.

* **Bastion Security Group**: A security group named "bastion" is created for the VPC, allowing SSH inbound traffic from any IP address (`0.0.0.0/0`) and all outbound traffic.
* **Bastion Host**: An EC2 instance named "Bastion Host" is created, using a specific AMI and `t2.nano` instance type. It's associated with the "bastion" security group and deployed in the first public subnet, using a specific key pair for SSH access. It's configured to automatically associate a public IP address. A script named `terminate_instance.sh` is provided as user data.

---

## AWS IAM Configuration

The AWS Identity and Access Management (IAM) configuration ensures secure and efficient access to various AWS services.

* **IAM Role: `ec2_ssm`**: This role is created for EC2 and Lambda services to interact with other AWS services under specific permissions. It trusts `ec2.amazonaws.com` and `lambda.amazonaws.com` to assume this role.
* **IAM Policies**:
    * `ssm_s3_rekognition`: Grants EC2 instances permissions to access SSM Parameter Store, S3, Rekognition, Auto Scaling groups, EC2 instances, network interfaces, and CloudWatch.
    * `CloudWatchPutMetricData`: Specifically allows EC2 instances to put metric data into CloudWatch.
    * `cloudfront_s3_access`: Grants access to CloudFront distributions and S3 objects.
* **IAM Role Policy Attachments**: The `cloudfront_s3_access`, `ssm_s3_rekognition`, and `cloudwatch` policies are attached to the `ec2_ssm` role.
* **IAM Instance Profile**: An IAM instance profile named "instance_profile" is created and associated with the `ec2_ssm` role, enabling EC2 instances to inherit these permissions.

---

## AWS CloudFront Configuration

The Terraform configuration creates an AWS CloudFront distribution and an origin access identity for efficient content delivery.

* **CloudFront Distribution**: A distribution named "s3_distribution" is created with two origins:
    * `S3Origin`: Configured to access the specified S3 bucket (`project_name-quiz-company.s3.eu-west-2.amazonaws.com`) using an origin access identity.
    * `EC2Origin`: A custom origin configured to use HTTPS only with TLSv1.1 and TLSv1.2.
    * The distribution is enabled, supports IPv6, and has `main.html` as the default root object.
    * **Cache Behaviors**:
        * Default cache behavior: Allows all HTTP methods, caches GET and HEAD requests, targets `EC2Origin`, and does not forward query strings or cookies.
        * Ordered cache behavior for `/static/*`: Targets `S3Origin`, allows and caches GET and HEAD requests.
        * Ordered cache behavior for `/media/`: Similar to `/static/` but for `/media/*` path.
    * Uses the default CloudFront certificate and has no geo restrictions.
    * Tagged with "client_name" and "quiz".
* **CloudFront Origin Access Identity (OAI)**: An OAI is created for the S3 bucket, allowing the CloudFront distribution to fetch objects while keeping them private from direct access.
* **Output**: The ID of the CloudFront distribution is outputted.

---

## AWS S3 Bucket Configuration

The AWS S3 bucket, `project_name-quiz-company`, is crucial for storing media and static files for the quiz application, and keys for application setup.

* **S3 Bucket Usage**:
    * Stores media files (images, videos) and static files (CSS, JavaScript, HTML) for the quiz application.
    * Holds keys (SSH keys, API keys, configuration files) necessary for setting up the main and background removal applications.
* **S3 Bucket Policy Configuration**:
    * **IAM Role Access (`AllowIAMRoleAccess`)**: Grants the `s3_access_role` permissions to put, get, and delete objects within the `keys/` directory.
    * **Public Read Access (`PublicReadAccessMedia` and `PublicReadGetObject`)**: Allows public read access to the `media/` and `static/` directories for serving content to users.
    * **EC2 Instance Access (`AllowAccessFromEC2Instance`)**: Provides broader permissions for the `s3_access_role` associated with EC2 instances to access and manipulate objects in `static/`, `project_name-quiz.js`, and `keys/` directories.

---

## Main Application Setup

The main application is hosted on an AWS EC2 instance, configured using Terraform and Ansible.

### AWS EC2 Instance Configuration (Terraform and Ansible)

* **Terraform Configuration**:
    * **Instance Details**: `t4g.small` instance type, associated with `public_instance_sg` security group and a specific subnet.
    * **Public IP Assignment**: Configured with a public IP address for external accessibility.
    * **IAM Role Integration**: Linked with the `s3_access_role` IAM role.
    * **User Data Provisioning**: Uses the `main_application.sh` script to feed environment variables.
* **Ansible Configuration (`main_application.sh`)**:
    * **System and Software Setup**: Updates packages and installs Python3, pip, Nginx, Celery, and related tools.
    * **Environment Configuration**: Sets up environment variables for AWS, database, and Django.
    * **Security and Repository Setup**: Manages SSH keys, adds Bitbucket to known hosts, and clones the application code.
    * **Application and Database Configuration**: Includes Python package installation, PostgreSQL setup, Nginx configuration, and SSL certificate management.
    * **Backup and Static File Management**: Scripts for PostgreSQL backups to S3 and Django static file management.
    * **Ansible Playbook**: Automates the entire setup, ensuring the web server and database are configured, and the application is ready.

### AWS Security Group Configuration

The `public_instance_sg` security group defines network security rules.

* **Ingress Rules**:
    * **SSH Access (port 22)**: Rules `rule_1`, `rule_4`, `rule_5`, and `rule_6` permit SSH access from predetermined IP addresses.
    * **Web Traffic (port 80 and port 443)**: Rules `rule_2`, `rule_3`, and `rule_7` enable HTTP and HTTPS traffic.
    * **Application-Specific Traffic**: Rules `rule_8`, `rule_9`, and `allow_http_8000` allow traffic on custom ports like 5555, 5432, and 8000.
    * **Security Consideration**: Rule `rule_5` permits unrestricted SSH access.
* **Egress Rules**: Allows all outbound traffic for communication with external services.

---

## Background Removal Setup

The background removal functionality is a resource-intensive task, set up with a dedicated and scalable AWS configuration.

### AWS Application Load Balancer (ALB) Configuration

* **ALB Creation**: An ALB named "ECS-FastAPI" is created to manage incoming traffic from the main application.
* **Security and Network**: Associated with security groups and deployed across public subnets for high availability and security.
* **Functionality**: Distributes incoming traffic from the main application across multiple EC2 instances in the Auto Scaling Group, ensuring load management and high availability while keeping instances isolated from the internet.

### AWS Auto Scaling Group (ASG) Configuration

* **ASG Setup**: An Auto Scaling Group named "IaC-Prod" is configured to scale EC2 instances in and out based on demand.
* **Subnet Association**: Associated with private subnets, ensuring secure background removal tasks without direct internet exposure.
* **Scaling Policies**: Includes policies for scaling up and down based on CPU utilization for efficient load handling.
* **Health Checks**: Utilizes ELB health checks to ensure healthy instances within the ASG.

### AWS Launch Template Configuration

* **Launch Template Creation**: A launch template named "machine-aws" defines the configuration of EC2 instances launched in the ASG.
* **Instance Specifications**: Includes AMI, instance type, key name, and security groups.
* **User Data**: Incorporates the `ansible.sh` script, executed upon instance launch to set up the environment for the background removal application.

#### Ansible Script (`ansible.sh`)

This script sets up an environment for running an Ansible playbook on an Ubuntu system.

* **Environment Setup**: Updates system packages, installs necessary dependencies, and sets up logging.
* **Python and Ansible Installation**: Installs Python3, pip, and Ansible.
* **Directory and File Setup**: Creates necessary directories and files, and sets appropriate permissions.
* **Environment Variables**: Sets up environment variables related to AWS.
* **Ansible Playbook**: Creates an Ansible playbook with tasks to:
    * Install Python3, virtualenv, and AWS CLI.
    * Retrieve the instance ID.
    * Install and configure the CloudWatch agent.
    * Retrieve the SSH key from AWS SSM and set it up for the `ubuntu` user.
    * Ensure the `/home/ubuntu/tcc` directory is owned by `ubuntu`.
    * Clone the git repository `project_name-api.git` from Bitbucket.
    * Install Python packages from `requirements.txt` in a virtual environment.
    * Move the `.env` file to the project directory.
    * Start the server using uvicorn.
* **Playbook Execution**: Executes the Ansible playbook as the `ubuntu` user.
* **Health Check**: Performs a health check by making a request to `http://localhost:8000/healthcheck` until a response is received.
* **Lifecycle Action Completion**: Completes the lifecycle action for the AWS Auto Scaling group.

### AWS Auto Scaling Lifecycle Hook

* **Lifecycle Hook**: A lifecycle hook named "lifecycle-hook" is configured for the ASG to manage instance initialization, ensuring new instances are fully operational before receiving traffic.

---

## Security and Reliability

The AWS architecture for the `project_name` project prioritizes security and reliability through several key measures.

### Security Measures

* **Segmentation**: VPC and subnet design segregates resources, limiting exposure and risk.
* **Access Control**: Security groups, IAM roles, and policies tightly control access to AWS resources.
* **Encryption and Certificates**: Use of HTTPS and SSL certificates ensures secure data transmission.

### Reliability and Performance

* **Load Balancing**: The ALB efficiently distributes traffic, enhancing application availability and reliability.
* **Auto Scaling**: ASG dynamically adjusts resources to meet demand, ensuring consistent performance.
* **Health Checks and Monitoring**: Continuous monitoring and health checks enable quick detection and response to issues.

### Risk Mitigation

* **Lambda Function**: Temporarily restricts access to the resource-intensive background removal function during scaling events, mitigating the risk of overloading.
* **Lifecycle Hooks**: Ensure new instances are fully operational before accepting traffic, reducing the risk of service disruption.

---
