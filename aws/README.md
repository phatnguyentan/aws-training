# Table of Content
```
Chapter 01 - Understanding the Foundations of AWS Architecture
Chapter 02 - The AWS Well-Architected Framework
Chapter 03 - Designing Secure Access to AWS Resources
Chapter 04 - Designing Secure Workloads and Applications
Chapter 05 - Determining Appropriate Data Security Controls
Chapter 06 - Designing Resilient Architecture
Chapter 07 - Designing Highly Available and Fault-Tolerant Architecture
Chapter 08 - High-Performing and Scalable Storage Solutions
Chapter 09 - Designing High-Performing and Elastic Compute Solutions
Chapter 10 - Determining High-Performing Database Solutions
Chapter 11 - High-Performing and Scalable Networking Architecture
Chapter 12 - Designing Cost-Optimized Storage Solutions
Chapter 13 - Designing Cost-Effective Compute Solutions
Chapter 14 - Designing Cost-Effective Database Solutions
Chapter 15 - Designing Cost-Effective Network Architectures
```
# Chapter 01
:link: [Establishing your cloud foundation on AWS](https://docs.aws.amazon.com/whitepapers/latest/establishing-your-cloud-foundation-on-aws/capabilities.html)

![AWS services](/aws/images/cloud-foundations-capabilities-full-list.d858b919fb2c4dcb3b27628ba91a1896b1b3e020.png)

```
There are six categories to help you establish a cloud foundation.
- Governance, Risk Management, and Compliance
- Operation
- Security
- Infrastructure
- Business Continuity
- Finance
```

## 🗂️ Governance, Risk Management, and Compliance
> ***Governance, Risk Management, and Compliance*** (GRC) helps organizations set the foundation for meeting security and compliance requirements and define the overall policies your cloud environment should adhere to. The capabilities within this area help you define what needs to happen, defines your risk appetite, and informs alignment of internal policies.

### 🏷️ Tagging
> ***Tagging*** enables you to **group sets of resources** by **assigning metadata** to cloud resources for a variety of purposes. These purposes include access control (such as ABAC), cost reporting, and automation (such as patching for select tagged instances). Tagging can also be used to create new resource constructs for visibility or control (such as grouping together resources that make up a microservice, application, or workload). Tagging is fundamental to providing enterprise-level visibility and control. 🛂

### 💾 Log storage
> ***Log*** storage :memo: enables you to collect and store your environment logs centrally and securely. This will enable you to evaluate, monitor, alert, and audit access and actions performed on your cloud resources and objects.

### 📈 Forensics
> ***Forensics*** involves the analysis of log data and evidentially-captured images of potentially compromised resources, to determine whether a compromise occurred (and if so, how). Outcomes of root cause analysis resulting from forensic investigations are typically used to produce and motivate the application of preventative measures.

### 🎬 Service Onboarding
> ***Service Onboarding*** provides the ability to review and approve AWS services for use based on consideration of internal, compliance, and regulatory requirements. This capability includes risk assessment, documentation, implementation patterns, and the change communication aspects of service consumption.

### 🪪 Data De-Identification
> ***Data De-Identification*** enables you to discover and protect sensitive data as it is stored and processed (for example, national ID numbers, trade data, healthcare information).

### 📐 Governance
> ***Governance*** enables you to define and enforce business and regulatory policies for your cloud environment. Policies can include rules for your environment or risk definitions. A portion of your governance policies is embedded in other capabilities across your environment to ensure that you meet your requirements.

### 🗎 Audit & Assessment
> ***Audit & Assessment*** provides the ability to gather and organize documentary evidence to enable internal or independent assessment of your cloud environment. This capability allows you to validate assertions that all changes were performed in accordance with policy.

### 👨🏽‍💼 Change Management
> ***Change Management*** enables you to deploy planned alterations to all configurable items that are in an environment within the defined scope, such as production and test. An approved change is an action which alters resource configuration that is implemented with a minimized and accepted risk to existing IT infrastructure.

### 🎥 Records Management
> ***Records Management*** :department_store: enables you to store, retain, and secure your data according to your internal policies and regulatory requirements. Some examples may include financial records, transactional data, audit logs, business records, and personally identifiable information (PII).

![AWS service](/aws/images/AWS-services.png)

## ❔Questions
### Understanding the Foundations of AWS Architecture
> An organization has developed a popular social media enterprise. The application allows users to upload images and comments to share with other users. The organization must make sure that the uploaded images don’t contain any inappropriate content. The company does not have a lot of expertise and time for development of the safety mechanisms required. Which solution would meet the requirements of the social media application?
- [ ] Use Amazon SageMaker to detect inappropriate content.
- [ ] Use Amazon Comprehend to detect inappropriate content.
- [ ] Use AWS Fargate to deploy a custom machine learning model that will detect inappropriate content.
- [ ] Use Amazon Rekognition to detect inappropriate content using DetectModerationLabels operation.
<div style="background-color:#dff0d8">
Explanation:
You can use Amazon Rekognition and DetectModerationLabels operation to determine if an image contains inappropriate or offensive content.</br>
Reference(s): https://docs.aws.amazon.com/rekognition/latest/dg/procedure-moderate-images.html
</div></br>

> Your database is under increased load more than 50% of the time. To handle the higher loads more effectively, you’ve decided to resize your database instance. You’ve checked and confirmed that your licensing can handle the compute changes, and now you must determine when the changes will be applied. When could you choose to apply the changes? Choose two answers.

<div style="background-color:#dff0d8">
Explanation:
Database instance changes can be applied immediately or during the system maintenance window specified.</br>
Reference(s): https://aws.amazon.com/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/
</div><br>

> What are the six pillars of the AWS Well-Architected Framework?
- [ ] DevOps excellence, encryption, resiliency, reliability, performance efficiency, cost optimization
- [ ] Operational excellence, security, reliability, implementation, effectiveness, billing optimization
- [ ] Process excellence, security, resiliency, performance, efficiency, billing improvement
- [ ] Operational excellence, security, reliability, performance efficiency, cost optimization, sustainability.

<div style="background-color:#dff0d8">
Explanation:
The six pillars of the Well-Architected Framework consist of operational excellence, security, reliability, performance efficiency, sustainability, and cost optimization.</br>
Reference(s): https://aws.amazon.com/blogs/apn/the-6-pillars-of-the-aws-well-architected-framework/
</div>

### The AWS Well-Architected Framework
> You need help in protecting your EC2 instance from DDoS attacks. What solution will provide for custom EC2 DDoS protection?
- [ ] AWS WAF
- [ ] AWS Shield Standard
- [ ] AWS Shield Advanced
- [ ] Amazon GuardDuty
<div style="background-color:#dff0d8">
Explanation:
AWS Shield Advanced provides custom EC2 DDoS protection utilizing AWS technical professionals. AWS Shield Standard provides the DOS protection but cannot be customized for an individual customer. Amazon GuardDuty is designed to apply machine learning to a variety of network logs; it does not provide DDoS protections. AWS WAF by itself is incorrect as each customer manages the setup and monitoring of a standard WAF deployment.</br>
Reference(s): https://docs.aws.amazon.com/waf/latest/developerguide/waf-rules.html
</div></br>

> You are using an AWS managed service with a defined SLA. The service suddenly fails and is not available for several hours. After discussions with AWS, they agree that the service affected your operations. What are you entitled to because the service failed?
- [ ] You are not entitled to anything because AWS services fail from time to time.
- [ ] You are entitled to operation credits.
- [ ] You are entitled to a service credit.
- [ ] You are entitled to a cash refund.
<div style="background-color:#dff0d8">
Explanation:
When failures occur at AWS, typically you will have to prove that the failure affected your operation. If you can prove that the failure affected your operation, you will receive a service credit for the month that you are operating in. Sometimes failures are severe enough that Amazon will automatically generate credits, but this is rare.</br>
Reference(s): https://aws.amazon.com/compute/sla/
</div></br>

> What is the name of the AWS service that developers can use that is a managed Git service?
- [ ] AWS CodeRepo
- [ ] AWS CodeCommit
- [ ] AWS CodeDeploy
- [ ] AWS CodeBuild
<div style="background-color:#dff0d8">
Explanation:
AWS CodeCommit is a hosted Git solution managed by AWS. AWS CodeCommit will work natively with Git clients and enable IAM integration. AWS CodeRepo is not a service in AWS. AWS CodeDeploy is an AWS service used to deploy code to EC2 instances. AWS CodeBuild is used to create build artifacts. </br>
Reference(s): https://docs.aws.amazon.com/codecommit/latest/userguide/welcome.html
</div></br>

### Designing Secure Access to AWS Resources
![security](/aws/images/Live-AWS-Security-Panel-Slidedeck-1.png)
> What AWS service provides temporary credentials when an IAM role is used?
- [ ] Cognito
- [ ] IAM
- [ ] Security Token Service
- [ ] Secrets Manager
<div style="background-color:#dff0d8">
Explanation:
Security Token Service provides temporary credentials for roles.</br>
Reference(s): https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html
</div></br>
