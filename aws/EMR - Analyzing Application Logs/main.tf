provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-log-bucket-123456"  # Change to a unique bucket name
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "processed_bucket" {
  bucket = "my-processed-logs-bucket-123456"  # Change to a unique bucket name
  acl    = "private"
}

resource "aws_emr_cluster" "log_processing_cluster" {
  name          = "LogProcessingCluster"
  release_label = "emr-6.10.0"  # Check for the latest EMR version
  applications  = ["Spark"]

  ec2_attributes {
    key_name          = "my-key-pair"  # Change to your key pair name
    subnet_id        = "subnet-12345678"  # Change to your subnet ID
    emr_managed_master_security_group = aws_security_group.cluster_sg.id
    emr_managed_slave_security_group = aws_security_group.cluster_sg.id
  }

  master_instance_type = "m5.xlarge"
  core_instance_type   = "m5.xlarge"
  core_instance_count  = 2

  bootstrap_action {
    path = "s3://my-log-bucket-123456/bootstrap.sh"  # Path to your bootstrap script, if needed
  }

  steps {
    name = "ProcessLogs"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "command-runner.jar"
      args = [
        "spark-submit",
        "--deploy-mode", "cluster",
        "s3://my-log-bucket-123456/spark_jobs/log_analysis.py"  # Path to your Spark job
      ]
    }
  }

  tags = {
    Name = "LogProcessingEMR"
  }
}

resource "aws_security_group" "cluster_sg" {
  name        = "emr-cluster-sg"
  description = "Security group for EMR cluster"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to restrict access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}