# AWS CI/CD Pipeline with GitHub Integration

This project demonstrates how to implement a **Continuous Integration (CI)** pipeline on the AWS platform using managed AWS services. It covers setting up a pipeline that pulls code from a GitHub repository, builds a Docker image using AWS CodeBuild, and stores sensitive information securely using AWS Systems Manager. 


In the regular implementation of CI, when a user commits any changes to the github repository,we configure a webhook which triggers jenkins which is where declarative pipelines are written using groovy scripts. Jenkins acts as an orchestartor, it is mainly responsible for 2 actions - **for the implementation of CI and invoking the CD**. Similar to this approach AWS has dedicated services which are used for the same purpose. In the way how webhook in github is used to trigger the jenkins, In AWS, code commit is used to trigger code pipeline, the Code pipeline is responsible for **invoking both CI and CD.**. In general approach jenkins perform CI and invokes CD, where as in AWS, Code pipeline just invokes both the CI and CD and CI is performed with the service called **Codebuild** and with **Codedeploy** CD is handled and deploy it to either K8S or ECS or EC2.

---

## Prerequisites

- **AWS account**
- **Basic knowledge of AWS services** such as CodePipeline, CodeBuild, and Systems Manager
- **GitHub repository** containing the source code (Python Flask application in this case)
- **Docker Hub** account for image storage
- **IAM user** with appropriate permissions to manage AWS services

---

## Architecture Overview

The below displayed image is the complete architecture of the project. In this project the main focus is on Continuous Integration.

![AWS CI Architecture](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/aws_vpc_arch.png)

This architecture involves:
- **GitHub** as the source code repository.
- **AWS CodePipeline** for orchestrating the pipeline.
- **AWS CodeBuild** to build and test the application, along with Docker image creation.
- **AWS Systems Manager Parameter Store** for securely managing sensitive data (e.g., Docker Hub credentials).

The project can be implemented in any order, We need a place where users commits the changes to, we have a dedicated AWS versioned service called Codecomit, but due to less industry standard features and most of the people prefering Github over Codecommit, So AWS tookout the service for new users. So we will be using Github for this project.
  
---

## Steps to Implement the Project

### Step 1: Set up GitHub Repository

The first step in our CI journey is to set up a GitHub repository to store our Python application's source code. 

- Go to github.com and sign in to your account.
- Click on the "+" button in the top-right corner and select "New repository."
- Give your repository a name and an optional description.
- Choose the appropriate visibility option based on your needs.
- Initialize the repository with a README file.
- Click on the "Create repository" button to create your new GitHub repository.

### Step 2: Create the AWS CodeBuild Project

1. **Create a CodeBuild Project**:
   - In the AWS Console, go to **CodeBuild**.
   - Click on **Create Build Project**.
   - Name the project (e.g., `sample-python-flask-app`).
   - In the **Environment** section, select **Ubuntu** and choose the latest **runtime image**.
  
![Codebuild-Github](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/aws_vpc_arch.png)

Next create a Servicerole or use an existing role (In order for codebuild to perform certain actions (When services needs to perform some actions on other services we need to assign certain roles))
![service image](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/aws_vpc_arch.png)

2. **Configure BuildSpec**:
   Write the `buildspec.yml` that defines the build steps, including building the Docker image:
   ```yaml
   version: 0.2

   phases:
     install:
       runtime-versions:
         python: 3.11
       commands:
         - pip install -r requirements.txt

     build:
       commands:
         - docker build -t $DOCKER_REGISTRY_URL/$DOCKER_USERNAME/sample-python-flask-app:latest .
         - docker push $DOCKER_REGISTRY_URL/$DOCKER_USERNAME/sample-python-flask-app:latest

   environment_variables:
     DOCKER_USERNAME: "your-docker-username"
     DOCKER_REGISTRY_URL: "https://index.docker.io/v1/"
   ```

All the steps like checkout, build , UT, code scan in order for them to execute, we need to write the code for image creation, scanning. All these are written in the buildspec file. And since this file might be accessed by others we need to mask cerain information, so that important information like username, passwords wont be displayed to others. For this we use AWS System manager.

![AWS CI Architecture](https://github.com/harinath-az/DevOps_projects/blob/main/VPC/images/aws_vpc_arch.png)
---

### Step 3: Secure Sensitive Data using AWS Systems Manager

1. **Store Docker Credentials** in AWS Systems Manager:
   - Go to **Systems Manager** -> **Parameter Store**.
   - Create three parameters: Docker username, Docker password, and Docker registry URL. Store them securely using **SecureString** encryption.
   - In the `buildspec.yml`, reference these parameters.

2. **Grant IAM Role Permissions**:
   - Ensure the IAM role used by CodeBuild has access to the Systems Manager parameters.

---

### Step 4: Set up CodePipeline

1. **Create AWS CodePipeline**:
   - In **AWS CodePipeline**, select **GitHub** as the source stage.
   - Use the previously created CodeBuild project for the build stage.
   - Define triggers to start the pipeline when there are code commits to the GitHub repository.

2. **Test the Pipeline**:
   - Commit changes to the GitHub repository, and the pipeline should automatically trigger.
   - Verify the build and Docker image push to Docker Hub.

---

### Step 5: Test and Monitor

1. **Monitor the Build**:
   - Use AWS CodeBuild logs to monitor each step of the build process.
   
2. **Access Docker Hub**:
   - Check Docker Hub to ensure that the image was pushed successfully.

---

### Screenshots

- **AWS CodeBuild Configuration**:

  ![CodeBuild Configuration](https://example.com/aws-codebuild-screenshot.png)

- **CodePipeline Stages**:

  ![CodePipeline Stages](https://example.com/aws-codepipeline-screenshot.png)

---

## Conclusion

This project demonstrates how to build a CI pipeline on AWS using CodePipeline and CodeBuild, with GitHub integration and Docker image management. Sensitive information like Docker credentials is stored securely using AWS Systems Manager Parameter Store.

---

This `README.md` is structured similarly to the example you provided, tailored to the project you referenced from the transcript involving AWS CodePipeline, CodeBuild, GitHub, and Docker. You can further customize it with relevant links and screenshots.
