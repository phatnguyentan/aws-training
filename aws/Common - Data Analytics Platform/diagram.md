```mermaid
graph TD
  subgraph Data_Ingestion
    Kinesis[Amazon Kinesis Data Streams]
    S3_Raw[Amazon S3 - Raw Data]
  end

  subgraph Data_Processing
    Lambda[AWS Lambda]
    EMR[Amazon EMR]
    Glue[AWS Glue]
  end

  subgraph Data_Storage
    S3_Processed[Amazon S3 - Processed Data]
    Redshift[Amazon Redshift]
  end

  subgraph Data_Analysis
    Athena[Amazon Athena]
    QuickSight[Amazon QuickSight]
  end

  subgraph Security_and_Access_Control
    IAM_Roles[IAM Roles and Policies]
    Security_Groups[Security Groups]
    NACLs[Network ACLs]
  end

  subgraph Monitoring_and_Logging
    CloudWatch[Amazon CloudWatch]
    CloudTrail[AWS CloudTrail]
  end

  Kinesis -->|Ingests Data| S3_Raw
  S3_Raw -->|Triggers| Lambda
  Lambda -->|Processes Data| S3_Processed
  S3_Raw -->|Batch Processing| EMR
  S3_Raw -->|ETL Operations| Glue
  EMR -->|Stores Processed Data| S3_Processed
  Glue -->|Stores Processed Data| S3_Processed
  S3_Processed -->|Stores Data| Redshift
  Athena -->|Queries Data| S3_Processed
  QuickSight -->|Visualizes Data| Redshift
  IAM_Roles -->|Manages Access| Data_Ingestion
  IAM_Roles -->|Manages Access| Data_Processing
  IAM_Roles -->|Manages Access| Data_Storage
  IAM_Roles -->|Manages Access| Data_Analysis
  Security_Groups -->|Secures| Data_Ingestion
  Security_Groups -->|Secures| Data_Processing
  Security_Groups -->|Secures| Data_Storage
  Security_Groups -->|Secures| Data_Analysis
  NACLs -->|Secures| Data_Ingestion
  NACLs -->|Secures| Data_Processing
  NACLs -->|Secures| Data_Storage
  NACLs -->|Secures| Data_Analysis
  CloudWatch -->|Monitors| Data_Ingestion
  CloudWatch -->|Monitors| Data_Processing
  CloudWatch -->|Monitors| Data_Storage
  CloudWatch -->|Monitors| Data_Analysis
  CloudTrail -->|Logs| Data_Ingestion
  CloudTrail -->|Logs| Data_Processing
  CloudTrail -->|Logs| Data_Storage
  CloudTrail -->|Logs| Data_Analysis
```

Explanation
Data Ingestion: Data is ingested in real-time using Amazon Kinesis Data Streams and stored in Amazon S3 (Raw Data).
Data Processing: AWS Lambda processes data in real-time, while Amazon EMR and AWS Glue handle batch processing and ETL operations.
Data Storage: Processed data is stored in Amazon S3 (Processed Data) and Amazon Redshift for scalable storage and fast querying.
Data Analysis: Amazon Athena queries the processed data in S3, and Amazon QuickSight visualizes the data stored in Redshift.
Security and Access Control: IAM roles and policies manage access to all services, while security groups and network ACLs ensure secure access to resources.
Monitoring and Logging: Amazon CloudWatch monitors the performance and health of all services, and AWS CloudTrail logs user activity and API usage.