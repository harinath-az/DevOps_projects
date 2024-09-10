# Real-Time Production-Grade AWS Setup

This project demonstrates how to create a VPC Architecture that is used on Production environment. It implements a secure and scalable AWS architecture using key services like VPC, EC2, Load Balancer, Auto Scaling, NAT Gateway, and Bastion Host. It demonstrates the process of setting up a production-grade environment that handles real-time traffic and secures applications inside private subnets.

---

## Prerequisites

- **An active AWS account**
- **Basic knowledge of AWS services** such as VPC, EC2, Auto Scaling, and Load Balancers
- **Access to a key pair for SSH** to connect to the EC2 instances

---

## Architecture Overview

![AWS VPC Architecture](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/aws_vpc_arch.png)

The architecture involves:
- **VPC** with both **public** and **private subnets** across two Availability Zones (AZs) for redundancy.
- **NAT Gateway** in the public subnet to allow secure internet access for instances in the private subnet.
- **EC2 instances** in the private subnets, using an **Auto Scaling Group** for scaling based on traffic.
- **Application Load Balancer** in the public subnet to balance traffic between EC2 instances.
- **Bastion Host** for secure access to EC2 instances in the private subnet.

---

## Steps to Implement the Project

### Step 1: Create a VPC

1. In the **AWS Console**, search for **VPC** and choose **Create VPC**.
2. Select the **VPC with Public and Private Subnets** option.
3. Set up two **public subnets** and two **private subnets** across different Availability Zones (e.g., `us-east-1a` and `us-east-1b`).
4. Ensure the public subnets are associated with an **Internet Gateway** and the private subnets are attached to the correct **Route Table** with the **NAT Gateway** for secure internet access.
5. Elastic IPs are used by NAT Gateways to mask private IPs with public IPs so they can access the internet even if the EC2 instance goes down.(If we assign an elastic IP with ec2 instances, though the ec2 instance go down, the ip address will still stay the same. Elastic IP is used by NAT gateway to mask the private IP with the public IP such that they can be used over the internet.)

   ![VPC Architecture](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/VPC_ARCH.png)
   
   ![VPC Creation](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/vpc_creation.png)

---

### Step 2: Configure EC2 Instances Using Auto Scaling Group

1. In the **EC2 Dashboard**, go to **Auto Scaling Groups**.
2. Create a **Launch Template**. During this process, create a **Security Group** that allows:
   - **SSH (Port 22)** from anywhere for administrative access.
   - **HTTP (Port 8000)** to host your application.
   
   ![Auto Scaling Group Setup](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/auto_scaling.png)

3. These security group settings will be applied to the instances created by the Auto Scaling Group.
4. In the Auto Scaling configuration, specify the desired instance count (e.g., 2 instances), and distribute them across the **private subnets**.
5. Do not attach a Load Balancer during this step. Click **Next**, review your settings, and then create the Auto Scaling group.

   ![EC2 Auto Scaling Instances](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/auto_scaling_public.png)
   
6. After a few moments, check the **EC2 Dashboard** to confirm that two EC2 instances are created.

   ![EC2 Private Subnet Instances](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/EC2_private.png)

7. Since these instances are in the **private subnets**, they do not have public IPs. Therefore, you will need a **Bastion Host** to access them.

---

### Step 3: Set Up the Bastion Host

1. Launch an **EC2 instance** (Bastion Host) in the **public subnet**.
2. Configure the security group to allow **SSH access**.
3. Ensure the Bastion Host is in the same **VPC** and has a **Public IP** to allow you to SSH into it.

   ![Bastion Host Setup](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/bastion_host.png)

4. Use **SCP** to securely copy the key pair (PEM file) from your local machine to the Bastion Host:
   ```bash
   scp -i /path/to/key.pem /path/to/key.pem ubuntu@<BastionHostPublicIP>:/home/ubuntu
   ```

5. SSH into the Bastion Host and verify the PEM file has been copied successfully:
   ```bash
   ssh -i /path/to/key.pem ubuntu@<BastionHostPublicIP>
   ```

---

### Step 4: Install Application on EC2 Instances

1. From the Bastion Host, SSH into the private EC2 instances:
   ```bash
   ssh -i AWS_VPC.pem ubuntu@<PrivateInstanceIP>
   ```
   
   ![SSH into EC2 Instances](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/cmd1.png)

2. Install a simple **Python HTTP server** on the EC2 instances:
   ```bash
   sudo apt update
   sudo apt install python3
   python3 -m http.server 8000
   ```
   
   ![Running Python Server](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/cmd3.png)

3. This will host the application on **Port 8000**, which will be accessed via the Load Balancer.

---

### Step 5: Create an Application Load Balancer

1. In the **EC2 Dashboard**, navigate to **Load Balancers** and select **Create Load Balancer**.
2. Choose **Application Load Balancer**, and set it to be **Internet-facing**.
3. Attach it to the **public subnets** across the Availability Zones.

   ![Load Balancer Setup](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/load_balancer.png)

4. Configure the **Security Group** to allow **HTTP traffic (Port 80)**.
5. Create a **Target Group** to register the EC2 instances in the private subnets, and configure health checks on **Port 8000**.

   ![Target Group Setup](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/target_group.png)

---

### Step 6: Test and Verify the Setup

1. Access the **Load Balancer's DNS** from your browser. You should be able to view the hosted **HTML page** from your application.
2. Traffic will be load-balanced between the two EC2 instances. If one instance is down or the app is not running, an error page will be displayed.

   ![Hosted Application](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/output1.png)

---

