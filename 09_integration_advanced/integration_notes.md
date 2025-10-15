# Advanced Integration & Scaling

## 🎯 Learning Objectives

- Understand enterprise integrations with Databricks
- Learn about multi-cloud deployments
- Explore advanced security and governance
- Plan for scaling beyond Community Edition

## 🌐 Enterprise Integrations

### Cloud Storage Integration

#### AWS S3 Integration
```python
# Configure S3 access
spark.conf.set("spark.hadoop.fs.s3a.access.key", "your-access-key")
spark.conf.set("spark.hadoop.fs.s3a.secret.key", "your-secret-key")

# Read from S3
df = spark.read.parquet("s3a://your-bucket/data/")

# Write to S3
df.write.mode("overwrite").parquet("s3a://your-bucket/output/")
```

#### Azure Blob Storage
```python
# Configure Azure Blob access
spark.conf.set("fs.azure.account.key.yourstorageaccount.blob.core.windows.net", "your-key")

# Read from Azure Blob
df = spark.read.parquet("wasbs://container@yourstorageaccount.blob.core.windows.net/data/")
```

#### Google Cloud Storage
```python
# Configure GCS access
spark.conf.set("google.cloud.auth.service.account.json.keyfile", "/path/to/service-account.json")

# Read from GCS
df = spark.read.parquet("gs://your-bucket/data/")
```

### Database Integrations

#### PostgreSQL Integration
```python
# Read from PostgreSQL
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://host:port/database") \
    .option("dbtable", "table_name") \
    .option("user", "username") \
    .option("password", "password") \
    .load()

# Write to PostgreSQL
df.write \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://host:port/database") \
    .option("dbtable", "output_table") \
    .option("user", "username") \
    .option("password", "password") \
    .mode("overwrite") \
    .save()
```

#### MySQL Integration
```python
# MySQL connection
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:mysql://host:port/database") \
    .option("dbtable", "table_name") \
    .option("user", "username") \
    .option("password", "password") \
    .option("driver", "com.mysql.cj.jdbc.Driver") \
    .load()
```

#### SQL Server Integration
```python
# SQL Server connection
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:sqlserver://host:port;databaseName=database") \
    .option("dbtable", "table_name") \
    .option("user", "username") \
    .option("password", "password") \
    .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver") \
    .load()
```

## 🔐 Security & Governance

### Identity and Access Management

#### Azure Active Directory Integration
```python
# Configure AAD authentication
spark.conf.set("spark.databricks.workspaceUrl", "https://your-workspace.cloud.databricks.com")
spark.conf.set("spark.databricks.auth.type", "AAD")
```

#### AWS IAM Integration
```python
# Configure IAM roles
spark.conf.set("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.InstanceProfileCredentialsProvider")
```

### Data Governance

#### Column-Level Security
```python
# Implement column-level access control
def apply_column_security(df, user_role):
    if user_role == "analyst":
        return df.select("public_columns")
    elif user_role == "admin":
        return df.select("*")
    else:
        return df.select("basic_columns")
```

#### Row-Level Security
```python
# Implement row-level filtering
def apply_row_security(df, user_id):
    return df.filter(col("user_id") == user_id)
```

### Encryption

#### Data Encryption at Rest
```python
# Configure encryption
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
```

#### Data Encryption in Transit
```python
# Configure SSL/TLS
spark.conf.set("spark.ssl.enabled", "true")
spark.conf.set("spark.ssl.trustStore", "/path/to/truststore")
```

## 🚀 Scaling Strategies

### Cluster Optimization

#### Auto-scaling Configuration
```python
# Configure auto-scaling
cluster_config = {
    "min_workers": 2,
    "max_workers": 10,
    "target_workers": 4,
    "autoscale": {
        "min_workers": 2,
        "max_workers": 8
    }
}
```

#### Resource Optimization
```python
# Optimize Spark configuration
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")
```

### Data Partitioning

#### Partitioning Strategies
```python
# Partition by date for time-series data
df.write.partitionBy("date").format("delta").save("/delta/events")

# Partition by category for analytical queries
df.write.partitionBy("category").format("delta").save("/delta/products")

# Z-ordering for query optimization
df.write.format("delta").option("optimizeWrite", "true").save("/delta/optimized")
```

#### Bucketing
```python
# Bucket data for join optimization
df.write.bucketBy(10, "user_id").saveAsTable("bucketed_table")
```

## 🔄 Data Pipeline Orchestration

### Apache Airflow Integration
```python
# Airflow DAG for Databricks jobs
from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksSubmitRunOperator

dag = DAG('databricks_pipeline', schedule_interval='@daily')

databricks_task = DatabricksSubmitRunOperator(
    task_id='databricks_job',
    databricks_conn_id='databricks_default',
    json={
        "notebook_task": {
            "notebook_path": "/Shared/etl_pipeline"
        }
    }
)
```

### Prefect Integration
```python
# Prefect flow for Databricks
from prefect import flow
from prefect_databricks import DatabricksJob

@flow
def databricks_etl():
    job = DatabricksJob(
        notebook_path="/Shared/etl_pipeline",
        cluster_id="your-cluster-id"
    )
    job.run()
```

## 📊 Monitoring & Observability

### Application Performance Monitoring
```python
# Custom metrics collection
import time
from datadog import initialize, statsd

def monitor_job_performance(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        execution_time = time.time() - start_time
        
        # Send metrics to monitoring system
        statsd.timing('databricks.job.execution_time', execution_time)
        return result
    return wrapper
```

### Log Aggregation
```python
# Centralized logging
import logging
from pythonjsonlogger import jsonlogger

# Configure structured logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(logHandler)
```

## 🌍 Multi-Cloud Deployment

### Cross-Cloud Data Replication
```python
# Replicate data across clouds
def replicate_to_aws(df):
    df.write.format("delta").mode("overwrite").save("s3a://aws-bucket/data/")

def replicate_to_azure(df):
    df.write.format("delta").mode("overwrite").save("wasbs://azure-container/data/")

def replicate_to_gcp(df):
    df.write.format("delta").mode("overwrite").save("gs://gcp-bucket/data/")
```

### Cloud-Specific Optimizations
```python
# AWS-specific optimizations
spark.conf.set("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.InstanceProfileCredentialsProvider")
spark.conf.set("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

# Azure-specific optimizations
spark.conf.set("spark.hadoop.fs.azure.account.key.yourstorageaccount.blob.core.windows.net", "your-key")

# GCP-specific optimizations
spark.conf.set("spark.hadoop.google.cloud.auth.service.account.json.keyfile", "/path/to/service-account.json")
```

## 🔧 Advanced Features

### Delta Sharing
```python
# Share Delta tables securely
from delta.sharing import SharingClient

# Create sharing client
client = SharingClient(profile="default")

# Share table
client.create_share("my_share")
client.add_table("my_share", "my_table", "/path/to/table")
```

### Unity Catalog Integration
```python
# Use Unity Catalog for data governance
df = spark.read.table("catalog.schema.table")
df.write.mode("overwrite").saveAsTable("catalog.schema.output_table")
```

### Photon Engine
```python
# Enable Photon for better performance
spark.conf.set("spark.databricks.photon.enabled", "true")
spark.conf.set("spark.databricks.photon.adaptive.enabled", "true")
```

## 📈 Cost Optimization

### Compute Optimization
```python
# Use spot instances for cost savings
cluster_config = {
    "node_type_id": "i3.xlarge",
    "aws_attributes": {
        "spot_bid_price_percent": 100,
        "availability": "SPOT"
    }
}
```

### Storage Optimization
```python
# Optimize storage with compression
df.write.format("delta").option("compression", "zstd").save("/delta/compressed")

# Use appropriate file sizes
df.coalesce(10).write.format("delta").save("/delta/optimized")
```

## 🎯 Best Practices

### Security
- **Principle of least privilege**: Minimal required permissions
- **Data encryption**: Encrypt data at rest and in transit
- **Access controls**: Implement role-based access control
- **Audit logging**: Comprehensive audit trails

### Performance
- **Right-sizing**: Match workload to cluster size
- **Caching**: Cache frequently accessed data
- **Partitioning**: Optimize data layout
- **Monitoring**: Continuous performance monitoring

### Governance
- **Data lineage**: Track data flow and transformations
- **Data quality**: Implement quality checks and monitoring
- **Compliance**: Meet regulatory requirements
- **Documentation**: Maintain comprehensive documentation

## 🔗 Resources

- [Databricks Enterprise Features](https://docs.databricks.com/enterprise/index.html)
- [Multi-Cloud Deployment](https://docs.databricks.com/administration-guide/cloud-configurations/index.html)
- [Security Best Practices](https://docs.databricks.com/security/index.html)
- [Performance Tuning](https://docs.databricks.com/optimizations/index.html)

---

**Integration Status:** ✅ Ready for enterprise deployment!
