### Scenario: Scalable Web Application with CloudFormation

**Business Context**:  
You are developing a web application that needs to handle varying traffic loads while ensuring high availability and automatic scaling. You want to deploy multiple resources, including EC2 instances, a load balancer, an RDS database, and an S3 bucket for static assets.

#### Infrastructure Components:

1. **VPC**: A Virtual Private Cloud to host all resources.
2. **Subnets**: Public and private subnets for better security.
3. **EC2 Auto Scaling Group**: For scaling the web servers based on demand.
4. **Elastic Load Balancer (ELB)**: To distribute incoming traffic.
5. **RDS Instance**: For the database backend.
6. **S3 Bucket**: For storing static content (like images, CSS, and JavaScript files).

### CloudFormation Template

Here’s a simplified CloudFormation YAML template to set up the above infrastructure:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Scalable Web Application Infrastructure

Parameters:
  VpcCIDR:
    Type: String
    Default: "10.0.0.0/16"
    Description: CIDR block for the VPC

  InstanceType:
    Type: String
    Default: "t2.micro"
    Description: EC2 instance type

Resources:

  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: MyVPC

  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: "10.0.1.0/24"
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: PublicSubnet

  PrivateSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: "10.0.2.0/24"
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PrivateSubnet

  InternetGateway:
    Type: AWS::EC2::InternetGateway

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: MyLoadBalancer
      Subnets:
        - !Ref PublicSubnet
      SecurityGroups:
        - !Ref LoadBalancerSecurityGroup

  LoadBalancerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allow HTTP and HTTPS traffic
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      LaunchConfigurationName: !Ref LaunchConfiguration
      MinSize: 2
      MaxSize: 5
      VPCZoneIdentifier:
        - !Ref PrivateSubnet
      TargetGroupARNs:
        - !Ref TargetGroup

  LaunchConfiguration:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ami-12345678  # Replace with your AMI ID
      SecurityGroups:
        - !Ref InstanceSecurityGroup

  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allow SSH and HTTP traffic
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      VpcId: !Ref VPC
      Port: 80
      Protocol: HTTP
      HealthCheckProtocol: HTTP
      HealthCheckPath: /
      TargetType: instance

  RDSInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceClass: db.t2.micro
      Engine: mysql
      MasterUsername: admin
      MasterUserPassword: password123  # Change this to a secure password
      AllocatedStorage: 20
      VPCSecurityGroups:
        - !Ref RDSSecurityGroup

  RDSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allow MySQL access
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          CidrIp: 10.0.2.0/24  # Private subnet

  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-static-assets-bucket

Outputs:
  LoadBalancerDNS:
    Value: !GetAtt LoadBalancer.DNSName
    Description: DNS name of the Load Balancer
```

### Instructions

1. **Replace Placeholder Values**:
   - Update the AMI ID in the `LaunchConfiguration` resource to match your desired Amazon Machine Image.
   - Set a secure password for the RDS instance.

2. **Create the Stack**:
   - Save the template to a file named `template.yaml`.
   - Use the AWS Management Console or AWS CLI to create a CloudFormation stack:
     ```bash
     aws cloudformation create-stack --stack-name MyWebAppStack --template-body file://template.yaml --capabilities CAPABILITY_IAM
     ```

3. **Monitor the Stack Creation**:
   - You can monitor the stack creation process via the AWS Management Console or using the AWS CLI.

4. **Access the Application**:
   - Once the stack is created, retrieve the Load Balancer DNS name from the Outputs section to access your web application.

### Outcome

- This CloudFormation template sets up a scalable web application infrastructure with an auto-scaling group, load balancer, RDS instance, and an S3 bucket for static assets.
- The architecture is designed to handle varying traffic loads while ensuring high availability and security.