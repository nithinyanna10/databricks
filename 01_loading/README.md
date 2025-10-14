# 01_loading - Data Loading and Basic Transformations

This folder contains notebooks and examples focused on data loading techniques and basic data transformations in Databricks using Apache Spark.

## 📁 Contents

- `notebook_2.ipynb` - Comprehensive data loading and transformation examples

## 🎯 Learning Objectives

By the end of this section, you will understand:
- How to load data from various sources in Databricks
- Basic data transformation operations
- Working with Spark DataFrames
- Data cleaning and preprocessing techniques

## 📊 Dataset Information

### Airlines Dataset
- **Source:** `/databricks-datasets/airlines`
- **Format:** CSV with headers
- **Content:** Flight data including delays, carriers, airports, and more
- **Use Case:** Perfect for learning data loading and transformation

## 🚀 Key Concepts Covered

### 1. Data Loading
```python
# Load CSV data with headers and schema inference
df = spark.read.csv("/databricks-datasets/airlines", header=True, inferSchema=True)
```

**Key Parameters:**
- `header=True`: First row contains column names
- `inferSchema=True`: Automatically detect data types
- `spark.read.csv()`: Spark's CSV reader method

### 2. Data Exploration
```python
# Display first 5 rows
df.show(5)

# Get basic statistics
df.describe().show()

# Check data types
df.printSchema()
```

### 3. Data Transformations

#### Column Selection
```python
# Select specific columns
df_selected = df.select("carrier", "dep_delay", "arr_delay")
```

#### Adding New Columns
```python
from pyspark.sql.functions import expr

# Create calculated column
df_new = df.withColumn("total_delay", expr("dep_delay + arr_delay"))
```

#### Data Cleaning
```python
# Remove duplicate rows
df_nodups = df.dropDuplicates()
```

## 📝 Notebook Walkthrough

### notebook_2.ipynb

This notebook demonstrates a complete data loading and transformation workflow:

1. **Data Loading Section**
   - Loads the airlines dataset from Databricks sample data
   - Uses proper schema inference
   - Displays sample data for verification

2. **Data Transformation Section**
   - Column selection techniques
   - Creating calculated fields
   - Data cleaning operations
   - Basic data quality checks

## 🔧 Common Data Loading Patterns

### Loading from Different Sources

#### CSV Files
```python
# Basic CSV loading
df = spark.read.csv("path/to/file.csv", header=True, inferSchema=True)

# With custom delimiter
df = spark.read.option("delimiter", "|").csv("path/to/file.csv")
```

#### JSON Files
```python
# Load JSON data
df = spark.read.json("path/to/file.json")

# Multi-line JSON
df = spark.read.option("multiLine", "true").json("path/to/file.json")
```

#### Parquet Files
```python
# Load Parquet (most efficient for Spark)
df = spark.read.parquet("path/to/file.parquet")
```

#### Database Connections
```python
# Load from JDBC source
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://host:port/database") \
    .option("dbtable", "table_name") \
    .option("user", "username") \
    .option("password", "password") \
    .load()
```

## 🛠️ Best Practices

### 1. Schema Management
- Always use `inferSchema=True` for initial exploration
- Define explicit schemas for production workloads
- Use `printSchema()` to verify data types

### 2. Performance Optimization
- Use Parquet format for better performance
- Consider partitioning for large datasets
- Use appropriate data types to save memory

### 3. Data Quality
- Check for null values: `df.filter(df.column.isNull()).count()`
- Validate data ranges and formats
- Handle missing data appropriately

## 📚 Common Transformations

### Column Operations
```python
from pyspark.sql.functions import col, when, isnan, isnull

# Rename columns
df_renamed = df.withColumnRenamed("old_name", "new_name")

# Handle null values
df_cleaned = df.fillna({"column_name": "default_value"})

# Conditional transformations
df_conditional = df.withColumn("status", 
    when(col("delay") > 0, "delayed")
    .otherwise("on_time"))
```

### Filtering and Selection
```python
# Filter rows
df_filtered = df.filter(col("delay") > 0)

# Select multiple columns
df_selected = df.select("col1", "col2", "col3")

# Drop columns
df_dropped = df.drop("unwanted_column")
```

## 🎯 Exercises to Try

1. **Load a different dataset** from `/databricks-datasets/`
2. **Create calculated columns** based on existing data
3. **Filter data** based on specific criteria
4. **Handle missing values** in the dataset
5. **Export transformed data** to different formats

## 📖 Next Steps

After mastering data loading:
- **02_data_processing** - Advanced data transformations
- **03_analytics** - SQL queries and analytics
- **04_visualization** - Data visualization techniques

## 🔗 Resources

- [Spark SQL Documentation](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [Databricks Data Sources](https://docs.databricks.com/data/data-sources/index.html)
- [Spark DataFrame API](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/dataframe.html)

---

**Learning Status:** ✅ Data loading fundamentals mastered  
**Next Phase:** Advanced data processing and transformations
