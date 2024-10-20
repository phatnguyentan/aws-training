import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count

def main():
    # Create a Spark session
    spark = SparkSession.builder \
        .appName("LogAnalysis") \
        .getOrCreate()

    # Input and output paths
    input_path = "s3://my-log-bucket-123456/application-logs/"  # Change to your input path
    output_path = "s3://my-processed-logs-bucket-123456/processed-logs/"  # Change to your output path

    # Read the application logs from S3
    logs_df = spark.read.json(input_path)

    # Show the schema (optional)
    logs_df.printSchema()

    # Process logs: Calculate average response time and count of each status code
    processed_df = logs_df.groupBy("status_code").agg(
        avg_response_time=avg("response_time"),
        count_of_requests=count("status_code")
    )

    # Show the results (optional)
    processed_df.show()

    # Write processed data back to S3 in a Parquet format
    processed_df.write.mode("overwrite").parquet(output_path)

    # Stop the Spark session
    spark.stop()

if __name__ == "__main__":
    main()