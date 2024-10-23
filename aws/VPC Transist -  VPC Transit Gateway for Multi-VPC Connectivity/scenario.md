### Scenario: VPC Transit Gateway for Multi-VPC Connectivity

**Background:**
Company X operates a large-scale cloud infrastructure on AWS with multiple VPCs for different departments: Development, Testing, and Production. Each VPC is in the same AWS region but needs to communicate securely and efficiently. To simplify management and enhance connectivity, the company decides to implement a VPC Transit Gateway.

- **Development VPC:**
  - VPC ID: `vpc-dev-111111`
  - CIDR Block: `10.0.0.0/16`
  - Hosts development resources.

- **Testing VPC:**
  - VPC ID: `vpc-test-222222`
  - CIDR Block: `10.1.0.0/16`
  - Hosts testing environments.

- **Production VPC:**
  - VPC ID: `vpc-prod-333333`
  - CIDR Block: `10.2.0.0/16`
  - Hosts the live production application.

### Objective:
Establish a VPC Transit Gateway to enable seamless communication between the Development, Testing, and Production VPCs while maintaining network isolation.

### Steps to Set Up VPC Transit Gateway

1. **Create a Transit Gateway:**
   - Company X creates a Transit Gateway in the AWS Management Console, allowing centralized connectivity for all VPCs.

2. **Attach VPCs to the Transit Gateway:**
   - Attach the Development VPC (`vpc-dev-111111`) to the Transit Gateway.
   - Attach the Testing VPC (`vpc-test-222222`) to the Transit Gateway.
   - Attach the Production VPC (`vpc-prod-333333`) to the Transit Gateway.

3. **Configure Route Tables:**
   - Configure the Transit Gateway route table to enable routing between all attached VPCs. For example:
     - Route for `10.0.0.0/16` (Development VPC) to the Transit Gateway.
     - Route for `10.1.0.0/16` (Testing VPC) to the Transit Gateway.
     - Route for `10.2.0.0/16` (Production VPC) to the Transit Gateway.

4. **Update VPC Route Tables:**
   - Update the route tables in each VPC to route traffic destined for the other VPCs through the Transit Gateway.
     - For the Development VPC, add routes for `10.1.0.0/16` and `10.2.0.0/16` via the Transit Gateway.
     - Repeat this for the Testing and Production VPCs.

5. **Modify Security Groups:**
   - Adjust security group rules in each VPC to allow traffic from the other VPCs. For example, the security group in the Production VPC should allow inbound traffic from the Development and Testing VPCs.

6. **Test Connectivity:**
   - Conduct tests to ensure that resources in the Development VPC can communicate with resources in the Testing and Production VPCs, and vice versa.

### Use Case:
With the Transit Gateway in place, developers can easily test new features from the Development VPC in a controlled environment in the Testing VPC before deploying them to Production. This setup allows for efficient resource sharing while maintaining clear boundaries and security for each environment.

### Conclusion:
Using a VPC Transit Gateway simplifies network management for multi-VPC architectures, enabling secure and scalable communication. This scenario demonstrates how Company X can enhance collaboration and efficiency across its cloud infrastructure.