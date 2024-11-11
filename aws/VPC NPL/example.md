### Example: Setting Up an AWS Network Load Balancer

#### Step 1: Log into AWS Management Console
- Go to the [AWS Management Console](https://aws.amazon.com/console/).
- Sign in with your credentials.

#### Step 2: Navigate to EC2
- In the Console, search for and select **EC2**.

#### Step 3: Load Balancers
- In the left navigation pane, scroll down to **Load Balancing** and click on **Load Balancers**.

#### Step 4: Create Load Balancer
- Click on the **Create Load Balancer** button.
- Select **Network Load Balancer**.

#### Step 5: Configure Basic Settings
- **Name**: Enter a name for your NLB (e.g., `MyNLB`).
- **Scheme**: Choose between **Internet-facing** or **Internal** based on your needs.
- **IP address type**: Choose between **IPv4** or **Dualstack** (for both IPv4 and IPv6).

#### Step 6: Configure Listeners
- **Listener**: By default, a listener for TCP on port 80 is created. You can modify this:
  - **Protocol**: Select TCP, TLS, or UDP.
  - **Port**: Specify the port (e.g., 80 for HTTP, 443 for HTTPS).

#### Step 7: Configure Availability Zones
- **Select VPC**: Choose the VPC where you want to deploy the NLB.
- **Availability Zones**: Select at least two Availability Zones for high availability.
- **Subnets**: Select the subnets in each Availability Zone where the load balancer will be deployed.

#### Step 8: Configure Target Groups
- **Create a new target group**:
  - **Target type**: Choose `Instance`, `IP`, or `Lambda` based on your architecture.
  - **Target group name**: Give a name (e.g., `MyTargetGroup`).
  - **Protocol**: Select TCP (or UDP, as needed).
  - **Port**: Specify the port on which your targets will receive traffic.

- **Health checks**: Configure health check settings (e.g., path for HTTP health checks, interval, timeout, etc.).

#### Step 9: Register Targets
- After creating the target group, you can add targets (EC2 instances, IPs, etc.):
  - Select the instances you want to register with this target group.
  - Click on **Add to registered**.

#### Step 10: Review and Create
- Review your settings.
- Click on **Create** to launch your Network Load Balancer.

#### Step 11: Update Security Groups
- Ensure that the security groups associated with your EC2 instances allow incoming traffic from the NLB.

#### Step 12: Test the Load Balancer
- After the NLB is created, note the DNS name provided by AWS.
- You can test the NLB by sending requests to the DNS name to see if it properly distributes traffic to the registered targets.

### Conclusion
An AWS Network Load Balancer provides a highly scalable and resilient way to manage traffic to your applications. By following these steps, you can set up an NLB that efficiently routes requests to your backend services. Always ensure that the associated resources are properly configured and secured to maintain the integrity and performance of your applications.