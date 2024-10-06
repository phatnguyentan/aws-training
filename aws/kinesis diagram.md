graph TD;
    A[IoT Sensors] -->|Telemetry Data| B[Kinesis Data Streams]
    B -->|Stream Processing| C[Consumer Application]
    C -->|Detect Anomalies| D[Alerts]
    C -->|Processed Data| E[Kinesis Data Firehose]
    E -->|Load to S3| F[Amazon S3]
    F -->|Query Data| G[Kinesis Data Analytics]
    G -->|Analyze Trends| H[Dashboard]
    
    B -->|Live Video Stream| I[Kinesis Video Streams]
    I -->|Real-Time Monitoring| J[Video Dashboard]
    
    C -->|Send Alerts| K[Fleet Manager]