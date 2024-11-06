Certainly! Here's a concrete example of how to implement AWS Service Control Policies (SCPs) for the scenario described above.

### Example SCPs for TechCorp

#### 1. Development OU SCP

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:*",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 2. Testing OU SCP

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "cloudformation:*",
        "servicecatalog:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 3. Production OU SCP

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalTag/Role": "IT-Security"
        }
      }
    }
  ]
}
```

### Explanation:

- **Development OU SCP:**
  - **Allow** EC2, S3, and Lambda services to enable development activities.
  - **Deny** IAM and CloudFormation actions to prevent developers from modifying security settings and creating new resources that could affect the environment.

- **Testing OU SCP:**
  - **Allow** EC2 and RDS services for testing purposes.
  - **Deny** CloudFormation and Service Catalog actions to prevent changes to production resources.
  - **Deny** the ability to assume roles, limiting cross-account access.

- **Production OU SCP:**
  - **Allow** only RDS and S3 to minimize exposure to other services.
  - **Deny** all other actions to prevent any unauthorized changes.
  - **Deny** IAM actions unless the user has the IT-Security role tag, ensuring that only authorized personnel can manage IAM roles.

### Conclusion

By implementing these SCPs, TechCorp can effectively manage access to AWS resources across its organization, ensuring that each department has the necessary permissions while maintaining tight security controls.