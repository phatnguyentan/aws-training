```mermaid
graph TD
  subgraph VPC
    direction TB
    IGW[Internet Gateway]
    NAT[NAT Gateway]
    RT_Public[Public Route Table]
    RT_Private[Private Route Table]
    SG_Web[Web Server Security Group]
    SG_DB[Database Security Group]
    NACL_Public[Public Subnet NACL]
    NACL_Private[Private Subnet NACL]
    S3[S3 Bucket]
    EIP[EIP for NAT Gateway]
    
    subgraph Public_Subnet
      direction TB
      EC2_Web[EC2 Web Server]
      EBS_Web[EBS Volume for Web Server]
    end
    
    subgraph Private_Subnet
      direction TB
      EC2_DB[EC2 Database Server]
      EBS_DB[EBS Volume for Database Server]
    end
    
    IGW --> RT_Public
    NAT --> RT_Private
    EIP --> NAT
    RT_Public --> Public_Subnet
    RT_Private --> Private_Subnet
    SG_Web --> EC2_Web
    SG_DB --> EC2_DB
    NACL_Public --> Public_Subnet
    NACL_Private --> Private_Subnet
    EC2_Web --> EBS_Web
    EC2_DB --> EBS_DB
    EC2_Web --> S3
  end
  
  IAM_Role[EC2 IAM Role]
  IAM_Policy[EC2 IAM Policy]
  IAM_Role --> IAM_Policy
  EC2_Web --> IAM_Role
  EC2_DB --> IAM_Role
```
Explanation
VPC: Contains the overall network environment.
Internet Gateway (IGW): Allows internet access to resources in the public subnet.
NAT Gateway: Enables instances in the private subnet to access the internet without exposing them to inbound internet traffic.
Route Tables: Configured for public and private subnets to manage traffic flow.
Security Groups: Applied to EC2 instances for traffic control.
Network ACLs: Provide an additional layer of security at the subnet level.
EC2 Instances: Deployed in public (web servers) and private (database servers) subnets.
EBS Volumes: Attached to EC2 instances for persistent storage.
S3 Bucket: Stores static assets.
IAM Roles and Policies: Manage permissions for EC2 instances and users.