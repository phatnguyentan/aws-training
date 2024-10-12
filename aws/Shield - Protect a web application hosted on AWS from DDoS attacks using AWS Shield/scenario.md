### Scenario Overview

**Objective**: Protect a web application hosted on AWS from DDoS attacks using AWS Shield.

### Components

1. **Web Application**: A simple web application hosted on Amazon EC2 or Amazon Elastic Load Balancer (ELB).
2. **AWS Shield**: Implement AWS Shield Standard for automatic protection against common DDoS attacks.
3. **AWS WAF**: Use AWS Web Application Firewall (WAF) to create rules for filtering malicious traffic.
4. **CloudWatch**: Monitor traffic patterns and set alarms for unusual activity.

### Steps to Implement

#### 1. **Set Up Your Web Application**

- **Create an EC2 Instance**:
  - Launch an EC2 instance and install a web server (e.g., Apache, Nginx).
  - Deploy a simple web application that serves static content.

#### 2. **Configure AWS Shield**

- **Shield Standard**:
  - AWS Shield Standard is automatically enabled for all AWS customers at no additional cost. It protects against common DDoS attacks.
  - **Action**: Simply ensure your resources (like ELB or CloudFront) are configured to use Shield.

- **Shield Advanced (optional)**:
  - If your application is at risk of larger or more sophisticated attacks, consider enabling Shield Advanced for additional protections and access to DDoS response team (DRT).
  - **Action**: Subscribe to AWS Shield Advanced through the AWS Management Console.

#### 3. **Set Up AWS WAF**

- **Create a Web ACL**:
  - Go to the AWS WAF console.
  - Create a Web ACL (Access Control List) and associate it with your web application (e.g., an Application Load Balancer).

- **Define Rules**:
  - Add rules to filter out malicious traffic. For example:
    - **Rate-based rules**: Block requests from IP addresses that exceed a specified request rate.
    - **IP Set rules**: Block or allow traffic from specific IP addresses or CIDR blocks.
    - **SQL Injection and XSS rules**: Use AWS-managed rules to protect against common web exploits.

#### 4. **Monitor Traffic with CloudWatch**

- **Set Up Metrics**:
  - Monitor metrics such as incoming traffic, request counts, and error rates using CloudWatch.
  - Create a CloudWatch dashboard to visualize these metrics.

- **Create Alarms**:
  - Set up CloudWatch alarms to notify you of unusual traffic patterns, such as a sudden spike in request rates or a high number of errors.
  - For example, set an alarm for when incoming requests exceed a certain threshold (e.g., 1000 requests per minute).

#### 5. **Testing and Validation**

- **Simulate Traffic**:
  - Use a tool like Apache JMeter or locust.io to generate traffic against your web application and validate that AWS Shield and WAF are effectively filtering out malicious requests.
  
- **Monitor Logs**:
  - Check AWS WAF logs in S3 or CloudWatch to analyze blocked requests and refine your rules.

### Example CloudFormation Template

Here's a simplified CloudFormation snippet to set up AWS WAF with an Application Load Balancer:

```yaml
Resources:
  MyWebACL:
    Type: AWS::WAFv2::WebACL
    Properties:
      Scope: REGIONAL
      DefaultAction:
        Allow: {}
      Rules:
        - Name: RateLimitRule
          Priority: 1
          Statement:
            RateBasedStatement:
              Limit: 1000
              AggregateKeyType: IP
          Action:
            Block: {}
          VisibilityConfig:
            SampledRequestsEnabled: true
            CloudWatchMetricsEnabled: true
            MetricName: RateLimit

  MyLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: MyLoadBalancer
      Subnets: 
        - subnet-abc123
        - subnet-def456
      SecurityGroups: 
        - sg-xyz789

  MyWebACLAssociation:
    Type: AWS::WAFv2::WebACLAssociation
    Properties:
      ResourceArn: !GetAtt MyLoadBalancer.Arn
      WebACLArn: !GetAtt MyWebACL.Arn
```

### Conclusion

By following these steps, you can effectively implement AWS Shield to protect your web application from DDoS attacks. Additionally, using AWS WAF allows for fine-grained control over incoming traffic, enhancing your application’s security posture. Monitoring with CloudWatch ensures you are alerted to any unusual activity, enabling quick responses to potential threats.