## Scenario: Deploying a Microservice with Harness, Helm, and Kubernetes

### Overview

You are tasked with deploying a microservice application called `MicroserviceApp` using Harness, a powerful continuous delivery platform, alongside Helm for managing Kubernetes applications. This setup will enable efficient deployments, rollbacks, and monitoring of the microservice, ensuring a smooth development and production workflow.

### 1. Prerequisites

- **Harness Account**: Ensure you have a Harness account with appropriate permissions to create applications, services, and pipelines.
- **Kubernetes Cluster**: Set up a running Kubernetes cluster, which can be either on a cloud provider (like AWS, GCP, or Azure) or on-premises.
- **Helm**: Install and configure Helm on your local machine or CI/CD environment to manage Kubernetes applications.
- **Harness Delegate**: Install a Harness Delegate within your Kubernetes cluster. This delegate facilitates communication between Harness and your Kubernetes environment.

### 2. Setup

#### Step 1: Create a Harness Application
- **Log in to Harness**: Access your Harness account.
- **Add Application**: Navigate to the Setup section and click on "Add Application."
- **Name Your Application**: Enter `MicroserviceApp` as the name for your new application.

#### Step 2: Add a Kubernetes Service
- **Go to Services**: Within your application dashboard, find the Services tab and click on "Add Service."
- **Select Deployment Type**: Choose Kubernetes as the deployment type.
- **Provide Service Name**: Name your service `MyMicroservice`.
- **Add Manifests or Helm Charts**: You can either upload your Kubernetes manifests or point to an existing Helm chart.

#### Step 3: Configure Helm Chart
- **Select Manifest Type**: In the service setup, select Helm as the manifest type.
- **Helm Chart Repository**: Provide the URL of your Helm chart repository and specify the chart name.
- **Values File**: If your chart requires custom configurations, specify the `values.yaml` file to override default values.

#### Step 4: Add an Environment
- **Go to Environments**: Navigate to the Environments section and click on "Add Environment."
- **Name Your Environment**: Enter `Production` as the environment name.
- **Add Infrastructure Definition**: Link your Kubernetes cluster to this environment to define where the application will be deployed.

#### Step 5: Create a Workflow
- **Navigate to Workflows**: Click on the Workflows tab and choose "Add Workflow."
- **Select Deployment Strategy**: Choose between a Canary or Rolling deployment strategy based on your requirements.
- **Add Deploy Step**: Include a Deploy Helm Chart step in the workflow.
- **Configure Helm Details**: Specify the release name and namespace for the Helm chart deployment.

#### Step 6: Create a Pipeline
- **Go to Pipelines**: Click on the Pipelines tab and select "Add Pipeline."
- **Add Stages**: Define stages in your pipeline, such as Build, Deploy, and Verify.
- **Select Deploy Stage**: In the Deploy stage, link to the workflow you created earlier.

#### Step ### Step 7: Trigger the Pipeline
- **Set Up Triggers**: Configure triggers to automate the pipeline execution. This ensures that deployments can be initiated on specific events, such as code commits.
- **Add Trigger**: Navigate to the Triggers tab and click on "Add Trigger."
- **Configure Trigger**: Set the trigger to start the pipeline on new commits to your repository, integrating seamlessly with your version control system.

### 3. Deployment

#### Step 1: Run the Pipeline
- **Navigate to Pipeline**: Go to your newly created pipeline in the Harness dashboard.
- **Click Run**: Initiate the pipeline by clicking the "Run" button.
- **Monitor Deployment**: Watch the deployment process in real-time through the Harness dashboard, which provides detailed logs and status updates.

#### Step 2: Verify Deployment
- **Check Kubernetes Status**: After the pipeline runs, verify the status of your Kubernetes pods and services using `kubectl get pods` and `kubectl get services`.
- **Ensure Application Health**: Confirm that the application is running as expected and is accessible.

#### Step 3: Rollback (if needed)
- **Identify Issues**: If you encounter issues with the deployment, you can quickly revert changes.
- **Navigate to Deployments**: Go to the Deployments section in Harness and find the recent deployment.
- **Click Rollback**: Select the previous stable version and click "Rollback" to revert to the last successful deployment.

### 4. Best Practices

- **Version Control**: Maintain your Helm charts and Kubernetes manifests in a version control system (like Git) to track changes and manage releases effectively.
- **Monitoring**: Implement monitoring tools (such as Prometheus, Grafana, or Harness’s own monitoring tools) to keep tabs on the health and performance of your microservices.
- **Security**: Ensure that your Kubernetes cluster and Helm charts are secure. Regularly audit permissions, network policies, and secrets management.

### Conclusion

This scenario outlines the steps to deploy a microservice using Harness, Helm, and Kubernetes effectively. By following this process, you can set up a robust CI/CD pipeline that allows for automated deployments, easy rollbacks, and efficient application management, ensuring that your microservice is delivered securely and reliably. This architecture not only enhances deployment efficiency but also supports scalability and maintainability in your development lifecycle.