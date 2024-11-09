Sharing a VPC resource across AWS accounts can be accomplished using AWS Resource Access Manager (RAM). This allows you to share resources like subnets, security groups, and more between accounts securely.

### Example: Sharing a VPC Subnet Across AWS Accounts

Here’s a step-by-step example of how to share a VPC subnet from one AWS account (Account A) with another AWS account (Account B).

#### Prerequisites

1. **Two AWS Accounts**: Ensure you have two AWS accounts set up (Account A and Account B).
2. **VPC and Subnet**: You need an existing VPC and subnet in Account A that you want to share.

### Step-by-step Guide

#### Step 1: Enable Resource Sharing with AWS RAM in Account A

1. **Open the AWS Management Console** in Account A.
2. Navigate to **Resource Access Manager**.
3. Click on **Create resource share**.

#### Step 2: Create Resource Share

1. **Name**: Enter a name for your resource share (e.g., `MyVPCShare`).
2. **Resources**: 
   - Click on **Add resources**.
   - Select **Subnets**.
   - Choose the subnet you want to share from the list and click **Add**.
3. **Principals**: 
   - Click on **Add principals**.
   - Enter the AWS account ID of Account B.
4. **Enable resource share**: Ensure the option to enable the resource share is checked.
5. Click **Create resource share**.

#### Step 3: Accept the Resource Share in Account B

1. **Switch to Account B** in the AWS Management Console.
2. Navigate to **Resource Access Manager**.
3. You should see a notification about the shared resource.
4. Click on **Shared with me** in the left navigation pane.
5. Find the resource share (e.g., `MyVPCShare`) and click on it.
6. Click on **Accept resource share**.

#### Step 4: Use the Shared Subnet in Account B

Once the resource share is accepted, you can use the shared subnet in Account B to launch instances or create resources.

1. Open the **VPC console** in Account B.
2. Click on **Subnets** to see the shared subnet listed there.
3. You can now launch EC2 instances in the shared subnet.

### Example of Launching an EC2 Instance in the Shared Subnet

1. **Open the EC2 console** in Account B.
2. Click on **Launch Instance**.
3. Choose an Amazon Machine Image (AMI).
4. Choose an instance type.
5. In the **Configure instance details** step:
   - **Network**: Select the VPC that contains the shared subnet.
   - **Subnet**: Choose the shared subnet.
6. Complete the rest of the steps (storage, tags, security groups).
7. Review and launch the instance.

### Conclusion

By following the steps above, you have successfully shared a VPC subnet from Account A to Account B using AWS Resource Access Manager. This setup allows resources in different accounts to utilize the same networking infrastructure, facilitating collaboration between teams or departments while maintaining isolation between accounts.

If you have specific questions or need guidance on other types of VPC resource sharing, feel free to ask!