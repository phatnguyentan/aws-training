### Scenario: Setting Up a Web Server on EC2

**Company Overview:**
ABC Tech is launching a new web application that needs to be hosted on an AWS EC2 instance. To streamline the deployment process, they want to use EC2 user data to automate the installation and configuration of a web server.

**Objective:**
To automatically install and configure an Apache web server on an EC2 instance during the launch using user data.

### Steps to Implement EC2 User Data

1. **Launch an EC2 Instance:**
   - Choose an Amazon Machine Image (AMI) such as Amazon Linux 2.
   - Select an instance type (e.g., t2.micro).
   - Ensure the instance has a security group allowing HTTP (port 80) traffic.

2. **Create User Data Script:**
   - Write a shell script to be executed on instance launch. This script will:
     - Update the package manager.
     - Install the Apache web server.
     - Start the Apache service.
     - Create a simple HTML page to confirm the setup.

   Here’s an example user data script:

   ```bash
   #!/bin/bash
   # Update the package manager
   yum update -y
   
   # Install Apache web server
   yum install httpd -y
   
   # Start the Apache service
   systemctl start httpd
   systemctl enable httpd
   
   # Create a simple HTML page
   echo "<html><h1>Welcome to ABC Tech!</h1></html>" > /var/www/html/index.html
   ```

3. **Add User Data to EC2 Launch Configuration:**
   - In the AWS Management Console, when launching the instance, there is an option to provide user data.
   - Paste the above script into the user data field.

4. **Launch the Instance:**
   - Complete the instance launch process. When the instance boots, it will execute the user data script.

5. **Access the Web Server:**
   - Once the instance is running, find its public IP address.
   - Open a web browser and navigate to `http://<instance-public-ip>`. You should see the welcome message.

### Conclusion

By using EC2 user data, ABC Tech can automate the initial setup of their web server, ensuring that every instance launched is configured consistently and quickly. This approach reduces manual setup time and helps maintain a streamlined deployment process for future instances.