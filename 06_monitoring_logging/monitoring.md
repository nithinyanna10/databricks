# Monitoring & Logging in Databricks

## 🎯 Learning Objectives

- Understand Spark UI for job monitoring
- Configure cluster log delivery
- Monitor resource usage and performance
- Set up alerting and notifications

## 📊 Spark UI Overview

### Key Components

#### 1. Jobs Tab
- **Purpose**: Overview of all Spark jobs
- **Information**: Job status, duration, stages
- **Use Cases**: Identify slow jobs, monitor progress

#### 2. Stages Tab
- **Purpose**: Detailed view of job stages
- **Information**: Task distribution, execution time
- **Use Cases**: Optimize data skew, identify bottlenecks

#### 3. Storage Tab
- **Purpose**: Cached RDDs and DataFrames
- **Information**: Memory usage, storage level
- **Use Cases**: Optimize caching strategy

#### 4. Environment Tab
- **Purpose**: Spark configuration and system info
- **Information**: Spark version, JVM settings
- **Use Cases**: Debug configuration issues

#### 5. Executors Tab
- **Purpose**: Executor status and metrics
- **Information**: CPU, memory, disk usage
- **Use Cases**: Monitor resource utilization

## 🔍 Monitoring Key Metrics

### Performance Metrics
- **Job Duration**: Total execution time
- **Stage Duration**: Individual stage times
- **Task Duration**: Individual task times
- **Throughput**: Records processed per second

### Resource Metrics
- **CPU Usage**: Percentage of CPU utilized
- **Memory Usage**: RAM consumption
- **Disk I/O**: Read/write operations
- **Network I/O**: Data transfer rates

### Data Metrics
- **Records Processed**: Total records handled
- **Data Skew**: Uneven data distribution
- **Shuffle Data**: Data movement between stages
- **Cache Hit Rate**: Cached data usage

## 📝 Logging Configuration

### Cluster Log Delivery

#### Step 1: Enable Log Delivery
1. Go to **Compute** → **Clusters**
2. Select your cluster
3. Click **Edit**
4. Go to **Advanced Options** → **Logging**
5. Configure:
   - **Destination**: DBFS path
   - **Log Types**: Driver logs, Executor logs
   - **Retention**: 30 days

#### Step 2: Log Structure
```
/dbfs/cluster-logs/
├── driver/
│   ├── stdout/
│   ├── stderr/
│   └── log4j/
└── executor/
    ├── stdout/
    ├── stderr/
    └── log4j/
```

#### Step 3: Access Logs
```python
# Read driver logs
driver_logs = spark.read.text("/dbfs/cluster-logs/driver/stdout/")

# Read executor logs
executor_logs = spark.read.text("/dbfs/cluster-logs/executor/stdout/")
```

## 🚨 Alerting Setup

### Email Alerts
```python
# Configure email notifications
import smtplib
from email.mime.text import MIMEText

def send_alert(subject, message):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = 'databricks@company.com'
    msg['To'] = 'admin@company.com'
    
    # Send email
    server = smtplib.SMTP('smtp.company.com')
    server.send_message(msg)
    server.quit()
```

### Slack Integration
```python
import requests
import json

def send_slack_alert(message):
    webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    payload = {"text": message}
    requests.post(webhook_url, json.dumps(payload))
```

### Custom Monitoring
```python
# Monitor job progress
def monitor_job_progress(job_id):
    # Get job status
    status = get_job_status(job_id)
    
    if status == "FAILED":
        send_alert("Job Failed", f"Job {job_id} has failed")
    elif status == "SUCCESS":
        send_alert("Job Completed", f"Job {job_id} completed successfully")
```

## 📈 Performance Monitoring

### Query Performance
```sql
-- Monitor query performance
SELECT 
    query_id,
    query_text,
    execution_time_ms,
    rows_returned,
    bytes_scanned
FROM system.query_history
WHERE execution_time_ms > 30000  -- Queries taking > 30 seconds
ORDER BY execution_time_ms DESC;
```

### Resource Utilization
```python
# Monitor cluster metrics
def get_cluster_metrics(cluster_id):
    metrics = {
        'cpu_usage': get_cpu_usage(cluster_id),
        'memory_usage': get_memory_usage(cluster_id),
        'disk_usage': get_disk_usage(cluster_id)
    }
    return metrics
```

### Data Quality Monitoring
```python
# Monitor data quality
def check_data_quality(table_path):
    df = spark.read.format("delta").load(table_path)
    
    # Check for null values
    null_counts = df.select([count(when(col(c).isNull(), c)).alias(c) for c in df.columns])
    
    # Check for duplicates
    duplicate_count = df.count() - df.dropDuplicates().count()
    
    # Check data freshness
    latest_timestamp = df.select(max("timestamp")).collect()[0][0]
    
    return {
        'null_counts': null_counts,
        'duplicate_count': duplicate_count,
        'latest_timestamp': latest_timestamp
    }
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Out of Memory Errors
- **Symptoms**: Job fails with OOM errors
- **Solutions**:
  - Increase cluster memory
  - Optimize data partitioning
  - Use broadcast joins
  - Implement data caching

#### 2. Data Skew
- **Symptoms**: Some tasks take much longer
- **Solutions**:
  - Repartition data
  - Use salting techniques
  - Optimize join strategies
  - Use bucketing

#### 3. Slow Queries
- **Symptoms**: Queries take too long
- **Solutions**:
  - Add indexes/partitions
  - Optimize SQL queries
  - Use appropriate data formats
  - Implement query caching

### Debugging Steps
1. **Check Spark UI** for job details
2. **Review logs** for error messages
3. **Monitor resources** for bottlenecks
4. **Analyze query plans** for optimization
5. **Test with smaller datasets**

## 📊 Monitoring Dashboard

### Key Metrics to Track
- **Job Success Rate**: Percentage of successful jobs
- **Average Execution Time**: Mean job duration
- **Resource Utilization**: CPU, memory, disk usage
- **Error Rate**: Failed job percentage
- **Cost Metrics**: Compute costs per job

### Dashboard Components
```sql
-- Job success rate
SELECT 
    DATE(start_time) as date,
    COUNT(*) as total_jobs,
    SUM(CASE WHEN state = 'SUCCESS' THEN 1 ELSE 0 END) as successful_jobs,
    (SUM(CASE WHEN state = 'SUCCESS' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as success_rate
FROM job_runs
GROUP BY DATE(start_time)
ORDER BY date;
```

## 🎯 Best Practices

### Monitoring
- **Set up alerts** for critical failures
- **Monitor trends** over time
- **Track costs** and optimize usage
- **Regular health checks**

### Logging
- **Structured logging** with consistent format
- **Log levels** appropriate for environment
- **Retention policies** for log storage
- **Centralized logging** for analysis

### Performance
- **Baseline metrics** for comparison
- **Regular optimization** reviews
- **Capacity planning** for growth
- **Cost optimization** strategies

## 🔗 Resources

- [Spark UI Documentation](https://spark.apache.org/docs/latest/web-ui.html)
- [Databricks Monitoring](https://docs.databricks.com/monitoring/index.html)
- [Cluster Logging](https://docs.databricks.com/clusters/configure.html#cluster-log-delivery)
- [Performance Tuning](https://docs.databricks.com/optimizations/index.html)

---

**Monitoring Status:** ✅ Ready for production monitoring!
