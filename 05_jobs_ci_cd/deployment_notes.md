# Databricks Jobs & CI/CD Deployment Guide

## 🎯 Learning Objectives

- Create automated Databricks jobs
- Set up CI/CD pipelines with GitHub Actions
- Configure job notifications and monitoring
- Understand production deployment practices

## 🚀 Job Creation Steps

### Step 1: Create a New Job
1. Navigate to **Workflows** → **Jobs** in Databricks
2. Click **Create Job**
3. Configure job settings:
   - **Name**: "Airlines ETL Pipeline"
   - **Type**: Multi-task job
   - **Timeout**: 1 hour
   - **Max concurrent runs**: 1

### Step 2: Add Tasks

#### Task 1: Data Ingestion
- **Task name**: `data_ingestion`
- **Type**: Notebook
- **Notebook path**: `/Shared/01_loading/notebook_2`
- **Cluster**: Create new cluster
  - **Runtime**: 13.3.x-scala2.12
  - **Node type**: i3.xlarge
  - **Workers**: 2
- **Parameters**:
  - `input_path`: `/databricks-datasets/airlines`
  - `output_path`: `/delta/airlines_bronze`

#### Task 2: Data Transformation
- **Task name**: `data_transformation`
- **Type**: Notebook
- **Notebook path**: `/Shared/07_data_pipeline/bronze_silver_gold`
- **Cluster**: Use existing cluster
- **Dependencies**: `data_ingestion`
- **Parameters**:
  - `bronze_path`: `/delta/airlines_bronze`
  - `silver_path`: `/delta/airlines_silver`
  - `gold_path`: `/delta/airlines_gold`

#### Task 3: Data Validation
- **Task name**: `data_validation`
- **Type**: Notebook
- **Notebook path**: `/Shared/06_monitoring_logging/data_quality_checks`
- **Cluster**: Use existing cluster
- **Dependencies**: `data_transformation`
- **Parameters**:
  - `table_path`: `/delta/airlines_gold`

### Step 3: Configure Notifications

#### Email Notifications
- **On start**: admin@company.com
- **On success**: data-team@company.com
- **On failure**: admin@company.com, data-team@company.com

#### Webhook Notifications (Slack)
- **Webhook URL**: `https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK`
- **Events**: Start, Success, Failure

### Step 4: Set Schedule
- **Schedule**: Daily at 6:00 AM UTC
- **Cron expression**: `0 0 6 * * ?`
- **Timezone**: UTC
- **Status**: Active

## 🔧 CI/CD Pipeline Setup

### GitHub Actions Workflow

#### Prerequisites
1. **Databricks Personal Access Token**
   - Go to User Settings → Developer → Access tokens
   - Generate new token
   - Add to GitHub Secrets as `DATABRICKS_TOKEN`

2. **Databricks Host URL**
   - Add to GitHub Secrets as `DATABRICKS_HOST`
   - Format: `https://your-workspace.cloud.databricks.com`

3. **Job ID**
   - Get job ID from Databricks UI
   - Add to GitHub Secrets as `DATABRICKS_JOB_ID`

#### Workflow Steps

1. **Code Checkout**
   ```yaml
   - name: Checkout code
     uses: actions/checkout@v3
   ```

2. **Environment Setup**
   ```yaml
   - name: Set up Python
     uses: actions/setup-python@v4
     with:
       python-version: '3.8'
   ```

3. **Databricks CLI Installation**
   ```yaml
   - name: Install Databricks CLI
     run: pip install databricks-cli
   ```

4. **Authentication**
   ```yaml
   - name: Configure Databricks CLI
     run: |
       echo "${{ secrets.DATABRICKS_HOST }}" | databricks configure --token
     env:
       DATABRICKS_TOKEN: ${{ secrets.DATABRICKS_TOKEN }}
   ```

5. **Deploy Notebooks**
   ```yaml
   - name: Deploy notebooks
     run: |
       databricks workspace import-dir \
         --source-dir ./01_loading \
         --target-path /Shared/01_loading \
         --overwrite
   ```

6. **Update Job Configuration**
   ```yaml
   - name: Update job configuration
     run: |
       databricks jobs reset \
         --job-id ${{ secrets.DATABRICKS_JOB_ID }} \
         --json-file ./05_jobs_ci_cd/databricks_job.json
   ```

## 📊 Job Monitoring

### Key Metrics to Track
- **Success Rate**: Percentage of successful runs
- **Execution Time**: Average job duration
- **Resource Usage**: CPU, memory, storage
- **Error Rate**: Failed task percentage
- **Cost**: Compute costs per run

### Monitoring Dashboard
Create a monitoring dashboard with:
- Job run history
- Success/failure trends
- Execution time trends
- Resource utilization
- Cost analysis

### Alerting Rules
- **Critical**: Job failure
- **Warning**: Execution time > 2x normal
- **Info**: Successful completion
- **Cost**: Monthly spend threshold

## 🔒 Security Best Practices

### Access Control
- **Principle of Least Privilege**: Minimal required permissions
- **Service Principals**: Use for automated jobs
- **Role-based Access**: Different roles for different teams

### Secrets Management
- **Environment Variables**: Store sensitive data
- **Azure Key Vault**: Enterprise secret management
- **Databricks Secrets**: Workspace-level secrets

### Network Security
- **VPC**: Isolate compute resources
- **Private Endpoints**: Secure data access
- **Firewall Rules**: Restrict network access

## 🚨 Troubleshooting

### Common Issues

#### Job Failures
1. **Check cluster logs**
   - Navigate to cluster → Logs
   - Look for error messages
   - Check resource constraints

2. **Validate notebook paths**
   - Ensure notebooks exist
   - Check parameter values
   - Verify dependencies

3. **Review task dependencies**
   - Check task order
   - Verify cluster availability
   - Review timeout settings

#### Performance Issues
1. **Optimize cluster size**
   - Monitor resource usage
   - Adjust worker count
   - Consider different node types

2. **Optimize code**
   - Use appropriate data formats
   - Implement caching
   - Optimize queries

3. **Schedule optimization**
   - Avoid peak hours
   - Consider timezone differences
   - Balance load across time

### Debugging Steps
1. **Check job run details**
2. **Review task logs**
3. **Validate input data**
4. **Test individual tasks**
5. **Check dependencies**

## 📈 Performance Optimization

### Cluster Configuration
- **Right-sizing**: Match workload to cluster size
- **Auto-scaling**: Enable for variable workloads
- **Spot instances**: Use for cost optimization
- **Caching**: Cache frequently accessed data

### Code Optimization
- **Partitioning**: Optimize data layout
- **Compression**: Use appropriate formats
- **Query optimization**: Efficient SQL/DataFrame operations
- **Resource management**: Proper memory allocation

### Cost Optimization
- **Scheduled jobs**: Run during off-peak hours
- **Resource pooling**: Share clusters across jobs
- **Termination policies**: Auto-terminate idle clusters
- **Monitoring**: Track and optimize costs

## 📚 Best Practices

### Development
- **Version control**: Use Git for all code
- **Testing**: Implement unit and integration tests
- **Documentation**: Maintain clear documentation
- **Code review**: Peer review all changes

### Deployment
- **Staging environment**: Test before production
- **Rollback plan**: Prepare for failures
- **Monitoring**: Implement comprehensive monitoring
- **Backup**: Regular data backups

### Operations
- **Runbooks**: Document operational procedures
- **Training**: Train team on new features
- **Maintenance**: Regular system maintenance
- **Updates**: Keep systems current

## 🔗 Resources

- [Databricks Jobs Documentation](https://docs.databricks.com/workflows/jobs.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Databricks CLI Documentation](https://docs.databricks.com/dev-tools/cli/index.html)
- [CI/CD Best Practices](https://docs.databricks.com/dev-tools/ci-cd/index.html)

---

**Deployment Status:** ✅ Ready for production automation!
