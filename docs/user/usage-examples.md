# 💻 Usage Examples

This guide provides comprehensive examples for using the Offline Python Runtime Docker container in various scenarios. From simple data analysis to complex ETL pipelines and enterprise database connectivity.

## 📊 Data Science Workflow

### Basic Data Analysis
```bash
# Create a data analysis environment
mkdir -p ./data-analysis
cat > ./data-analysis/analyze.py << 'EOF'
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Generate sample data
data = pd.DataFrame({
    'x': np.random.randn(1000),
    'y': np.random.randn(1000)
})

print(f"Data shape: {data.shape}")
print(f"Memory usage: {data.memory_usage().sum() / 1024:.2f} KB")
print("✅ Data analysis environment ready!")

# Basic statistics
print("\n📊 Basic Statistics:")
print(data.describe())

# Correlation analysis
print(f"\n🔗 Correlation: {data['x'].corr(data['y']):.3f}")
EOF

# Run analysis
podman run -v ./data-analysis:/home/appuser/data-analysis:Z \
           -it offline-python-runtime:latest \
           python ./data-analysis/analyze.py
```

### Advanced Data Processing with DuckDB
```bash
cat > ./data-analysis/advanced-analysis.py << 'EOF'
import pandas as pd
import numpy as np
import duckdb
from datetime import datetime, timedelta

def advanced_data_processing():
    """Advanced data processing example with DuckDB"""
    print("🚀 Starting advanced data processing...")
    
    # Generate complex dataset
    dates = [datetime.now() - timedelta(days=i) for i in range(365)]
    data = pd.DataFrame({
        'date': dates,
        'sales': np.random.randint(100, 1000, 365),
        'region': ['North', 'South', 'East', 'West'] * 91 + ['North'],
        'product': ['A', 'B', 'C'] * 121 + ['A'],
        'cost': np.random.uniform(10, 100, 365)
    })
    
    # Process with DuckDB
    conn = duckdb.connect(':memory:')
    conn.register('sales_data', data)
    
    # Complex analytics query
    result = conn.execute("""
        SELECT 
            region,
            product,
            COUNT(*) as transactions,
            SUM(sales) as total_sales,
            AVG(cost) as avg_cost,
            profit_margin as (SUM(sales) - SUM(cost)) / SUM(sales) * 100
        FROM sales_data 
        GROUP BY region, product
        ORDER BY total_sales DESC
    """).fetchdf()
    
    print("📊 Analytics Results:")
    print(result.head(10))
    
    # Time series analysis
    time_series = conn.execute("""
        SELECT 
            DATE_TRUNC('month', date) as month,
            SUM(sales) as monthly_sales,
            AVG(sales) as avg_daily_sales,
            COUNT(*) as days_active
        FROM sales_data 
        GROUP BY DATE_TRUNC('month', date)
        ORDER BY month
    """).fetchdf()
    
    print("\n📈 Monthly Trends:")
    print(time_series)
    
    return result, time_series

if __name__ == "__main__":
    advanced_data_processing()
    print("✅ Advanced data processing completed!")
EOF

podman run -v ./data-analysis:/home/appuser/data-analysis:Z \
           -it offline-python-runtime:latest \
           python ./data-analysis/advanced-analysis.py
```

## 🗄️ Oracle Database Connectivity

### Oracle Connection Setup
```bash
# Create Oracle connection test
cat > ./oracle-test.py << 'EOF'
import os
import oracledb

def setup_oracle_connection():
    """Setup and test Oracle database connection"""
    print("🗄️ Setting up Oracle connection...")
    
    # Oracle client initialization (required for thick mode)
    oracle_instantclient_path = os.environ.get("ORACLE_INSTANTCLIENT_PATH")
    if oracle_instantclient_path:
        oracledb.init_oracle_client(lib_dir=oracle_instantclient_path)
        print("✅ Oracle client initialized successfully")
    else:
        print("⚠️ Oracle client path not found, using thin mode")
    
    # Connection example (replace with your credentials)
    connection_params = {
        'user': os.environ.get('ORACLE_USER', 'your_user'),
        'password': os.environ.get('ORACLE_PASSWORD', 'your_password'),
        'dsn': os.environ.get('ORACLE_DSN', 'your_host:1521/your_service')
    }
    
    try:
        # Only attempt connection if credentials are provided
        if all(os.environ.get(key) for key in ['ORACLE_USER', 'ORACLE_PASSWORD', 'ORACLE_DSN']):
            connection = oracledb.connect(**connection_params)
            print("✅ Oracle connection established successfully")
            
            # Test query
            cursor = connection.cursor()
            cursor.execute("SELECT 'Hello from Oracle!' as message FROM dual")
            result = cursor.fetchone()
            print(f"📊 Database test result: {result[0]}")
            
            cursor.close()
            connection.close()
        else:
            print("ℹ️ Oracle environment variables not set - client ready for connection")
            print("📝 Set ORACLE_USER, ORACLE_PASSWORD, and ORACLE_DSN to connect")
            
    except Exception as e:
        print(f"❌ Oracle connection failed: {e}")
        print("🔧 Check your database connection parameters")
    
    return True

if __name__ == "__main__":
    setup_oracle_connection()
EOF

# Test Oracle connectivity
podman run -v ./oracle-test.py:/home/appuser/oracle-test.py:Z \
           -e ORACLE_USER=your_user \
           -e ORACLE_PASSWORD=your_password \
           -e ORACLE_DSN=your_host:1521/your_service \
           -it offline-python-runtime:latest \
           python /home/appuser/oracle-test.py
```

### Enterprise Oracle Integration
```bash
cat > ./enterprise-oracle.py << 'EOF'
import os
import oracledb
import pandas as pd
from datetime import datetime
import json

class EnterpriseOracleManager:
    """Enterprise-grade Oracle database manager"""
    
    def __init__(self):
        self.connection = None
        self.setup_connection()
    
    def setup_connection(self):
        """Setup Oracle connection with enterprise features"""
        print("🏢 Setting up enterprise Oracle connection...")
        
        try:
            # Initialize Oracle client
            oracle_instantclient_path = os.environ["ORACLE_INSTANTCLIENT_PATH"]
            oracledb.init_oracle_client(lib_dir=oracle_instantclient_path)
            
            # Enterprise connection with connection pooling
            pool = oracledb.create_pool(
                user=os.environ["ORACLE_USER"],
                password=os.environ["ORACLE_PASSWORD"],
                dsn=os.environ["ORACLE_DSN"],
                min=1,
                max=10,
                increment=1
            )
            
            self.connection = pool.acquire()
            print("✅ Oracle connection pool established")
            
        except Exception as e:
            print(f"❌ Connection setup failed: {e}")
            raise
    
    def execute_enterprise_query(self, query, params=None):
        """Execute query with enterprise error handling"""
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params or {})
            
            # Fetch results into pandas DataFrame
            columns = [col[0] for col in cursor.description]
            data = cursor.fetchall()
            df = pd.DataFrame(data, columns=columns)
            
            cursor.close()
            return df
            
        except Exception as e:
            print(f"❌ Query execution failed: {e}")
            return None
    
    def enterprise_data_export(self):
        """Example enterprise data export workflow"""
        print("📊 Running enterprise data export...")
        
        # Complex business query
        query = """
        SELECT 
            department_id,
            employee_id,
            salary,
            hire_date,
            CASE 
                WHEN salary < 50000 THEN 'Entry Level'
                WHEN salary BETWEEN 50000 AND 80000 THEN 'Mid Level'
                ELSE 'Senior Level'
            END as salary_grade,
            MONTHS_BETWEEN(SYSDATE, hire_date) as months_employed
        FROM employees
        WHERE hire_date >= ADD_MONTHS(SYSDATE, -24)
        ORDER BY salary DESC
        """
        
        result_df = self.execute_enterprise_query(query)
        
        if result_df is not None:
            print(f"📈 Found {len(result_df)} recent hires")
            print("💰 Salary distribution:")
            print(result_df['salary_grade'].value_counts())
            
            # Export to Excel
            result_df.to_excel('/home/appuser/enterprise_report.xlsx', index=False)
            print("📄 Report exported to enterprise_report.xlsx")
        
        return result_df

# Example usage (requires actual Oracle database)
manager = EnterpriseOracleManager()
# manager.enterprise_data_export()
print("🏢 Enterprise Oracle integration ready!")
EOF

podman run -v ./enterprise-oracle.py:/home/appuser/enterprise-oracle.py:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/enterprise-oracle.py
```

## 🔄 ETL Pipelines

### Complete ETL Pipeline
```bash
# Create ETL pipeline example
cat > ./etl-pipeline.py << 'EOF'
import pandas as pd
import duckdb
import pymongo
from datetime import datetime
import json
import os

class ETLPipeline:
    """Enterprise ETL pipeline with multiple data sources"""
    
    def __init__(self):
        print("🚀 Initializing ETL pipeline...")
        self.duckdb_conn = duckdb.connect(':memory:')
        
    def extract_data(self):
        """Extract data from multiple sources"""
        print("📤 Extracting data...")
        
        # Source 1: Generated transaction data
        transactions = pd.DataFrame({
            'transaction_id': range(1000),
            'timestamp': [datetime.now() - pd.Timedelta(hours=i) for i in range(1000)],
            'amount': np.random.uniform(10, 1000, 1000),
            'category': np.random.choice(['A', 'B', 'C'], 1000),
            'region': np.random.choice(['North', 'South', 'East', 'West'], 1000)
        })
        
        # Source 2: Customer data
        customers = pd.DataFrame({
            'customer_id': range(200),
            'name': [f'Customer_{i}' for i in range(200)],
            'segment': np.random.choice(['Premium', 'Standard', 'Basic'], 200),
            'join_date': [datetime.now() - pd.Timedelta(days=i*30) for i in range(200)]
        })
        
        # Source 3: Product data
        products = pd.DataFrame({
            'product_id': range(50),
            'name': [f'Product_{i}' for i in range(50)],
            'category': np.random.choice(['Electronics', 'Clothing', 'Food'], 50),
            'price': np.random.uniform(20, 500, 50)
        })
        
        return transactions, customers, products
    
    def transform_data(self, transactions, customers, products):
        """Transform and enrich data"""
        print("🔄 Transforming data...")
        
        # Register data in DuckDB for SQL processing
        self.duckdb_conn.register('transactions', transactions)
        self.duckdb_conn.register('customers', customers)
        self.duckdb_conn.register('products', products)
        
        # Complex transformation query
        enriched_data = self.duckdb_conn.execute("""
            SELECT 
                t.transaction_id,
                t.timestamp,
                t.amount,
                t.region,
                c.segment as customer_segment,
                p.category as product_category,
                p.price as unit_price,
                CASE 
                    WHEN t.amount > 500 THEN 'High Value'
                    WHEN t.amount > 200 THEN 'Medium Value'
                    ELSE 'Low Value'
                END as transaction_type,
                DATE_TRUNC('day', t.timestamp) as transaction_date
            FROM transactions t
            LEFT JOIN customers c ON (t.transaction_id % 200) = c.customer_id
            LEFT JOIN products p ON (t.transaction_id % 50) = p.product_id
            ORDER BY t.timestamp DESC
        """).fetchdf()
        
        print(f"📊 Enriched {len(enriched_data)} transactions")
        return enriched_data
    
    def load_data(self, data):
        """Load data to various targets"""
        print("📥 Loading data...")
        
        # Load to multiple formats
        output_dir = '/home/appuser/etl_output'
        os.makedirs(output_dir, exist_ok=True)
        
        # CSV export
        data.to_csv(f'{output_dir}/transactions.csv', index=False)
        
        # JSON export
        data.to_json(f'{output_dir}/transactions.json', orient='records', date_format='iso')
        
        # Parquet export
        data.to_parquet(f'{output_dir}/transactions.parquet')
        
        # Analytics summary
        summary = self.duckdb_conn.register('final_data', data).execute("""
            SELECT 
                transaction_date,
                COUNT(*) as transaction_count,
                SUM(amount) as total_amount,
                AVG(amount) as avg_amount,
                COUNT(DISTINCT region) as regions_active
            FROM final_data
            GROUP BY transaction_date
            ORDER BY transaction_date DESC
            LIMIT 10
        """).fetchdf()
        
        summary.to_csv(f'{output_dir}/daily_summary.csv', index=False)
        
        print(f"📄 Data exported to {output_dir}")
        print("📊 Summary statistics generated")
        
        return data, summary
    
    def run_pipeline(self):
        """Run complete ETL pipeline"""
        print("🚀 Starting complete ETL pipeline...")
        
        try:
            # Extract
            transactions, customers, products = self.extract_data()
            
            # Transform
            transformed_data = self.transform_data(transactions, customers, products)
            
            # Load
            final_data, summary = self.load_data(transformed_data)
            
            print("✅ ETL pipeline completed successfully!")
            return final_data, summary
            
        except Exception as e:
            print(f"❌ ETL pipeline failed: {e}")
            raise

# Run the pipeline
if __name__ == "__main__":
    pipeline = ETLPipeline()
    results = pipeline.run_pipeline()
    
    print("\n📈 Pipeline Results:")
    print(f"📊 Total records processed: {len(results[0])}")
    print(f"📅 Daily summary days: {len(results[1])}")
    print("🎉 Ready for production use!")
EOF

# Run ETL pipeline
podman run -v ./etl-pipeline.py:/home/appuser/etl-pipeline.py:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/etl-pipeline.py
```

## 🌐 Web Application Example

### Flask Web Application
```bash
cat > ./web-app.py << 'EOF'
from flask import Flask, jsonify, request
import pandas as pd
import numpy as np
from datetime import datetime
import os

app = Flask(__name__)

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'pandas': pd.__version__,
            'numpy': np.__version__,
            'oracle': 'ready' if os.environ.get('ORACLE_INSTANTCLIENT_PATH') else 'thin_mode'
        }
    })

@app.route('/api/data')
def get_data():
    """Generate sample data API"""
    data_size = request.args.get('size', 100, type=int)
    
    # Generate sample data
    data = pd.DataFrame({
        'id': range(data_size),
        'value': np.random.randn(data_size),
        'timestamp': [datetime.now().isoformat() for _ in range(data_size)]
    })
    
    return jsonify({
        'data': data.to_dict('records'),
        'count': len(data),
        'generated_at': datetime.now().isoformat()
    })

@app.route('/api/analytics')
def get_analytics():
    """Perform analytics on generated data"""
    sample_data = pd.DataFrame({
        'category': np.random.choice(['A', 'B', 'C'], 1000),
        'value': np.random.uniform(0, 100, 1000)
    })
    
    analytics = sample_data.groupby('category')['value'].agg(['mean', 'std', 'count']).to_dict()
    
    return jsonify({
        'analytics': analytics,
        'processed_at': datetime.now().isoformat()
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print(f"🌐 Starting web application on port {port}")
    app.run(host='0.0.0.0', port=port, debug=True)
EOF

# Run web application
podman run -p 5000:5000 \
           -v ./web-app.py:/home/appuser/web-app.py:Z \
           -e PORT=5000 \
           -d offline-python-runtime:latest \
           python /home/appuser/web-app.py
```

## 🧪 Machine Learning Example

### Scikit-learn Model Training
```bash
cat > ./ml-example.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
from datetime import datetime

def train_ml_model():
    """Complete machine learning pipeline"""
    print("🤖 Starting machine learning pipeline...")
    
    # Generate synthetic dataset
    np.random.seed(42)
    n_samples = 10000
    
    data = pd.DataFrame({
        'feature_1': np.random.randn(n_samples),
        'feature_2': np.random.randn(n_samples),
        'feature_3': np.random.uniform(0, 100, n_samples),
        'feature_4': np.random.choice([0, 1], n_samples),
        'feature_5': np.random.exponential(2, n_samples)
    })
    
    # Create target variable
    data['target'] = (
        (data['feature_1'] > 0) & 
        (data['feature_3'] > 50) & 
        (data['feature_5'] < 5)
    ).astype(int)
    
    print(f"📊 Dataset: {len(data)} samples, {len(data.columns)} features")
    print(f"🎯 Target distribution: {data['target'].value_counts().to_dict()}")
    
    # Split data
    X = data.drop('target', axis=1)
    y = data['target']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Feature scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    print("🎓 Training model...")
    model.fit(X_train_scaled, y_train)
    
    # Make predictions
    y_pred = model.predict(X_test_scaled)
    
    # Evaluate model
    accuracy = accuracy_score(y_test, y_pred)
    print(f"📈 Model Accuracy: {accuracy:.3f}")
    
    print("\n📊 Classification Report:")
    print(classification_report(y_test, y_pred))
    
    # Feature importance
    feature_importance = pd.DataFrame({
        'feature': X.columns,
        'importance': model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print("\n🎯 Feature Importance:")
    print(feature_importance)
    
    return model, scaler, feature_importance

def save_results(model, scaler, feature_importance):
    """Save model results"""
    import joblib
    
    output_dir = '/home/appuser/ml_results'
    import os
    os.makedirs(output_dir, exist_ok=True)
    
    # Save model and scaler
    joblib.dump(model, f'{output_dir}/random_forest_model.pkl')
    joblib.dump(scaler, f'{output_dir}/feature_scaler.pkl')
    
    # Save feature importance
    feature_importance.to_csv(f'{output_dir}/feature_importance.csv', index=False)
    
    print(f"💾 Results saved to {output_dir}")
    
    return output_dir

# Run ML pipeline
if __name__ == "__main__":
    model, scaler, importance = train_ml_model()
    save_results(model, scaler, importance)
    print("✅ Machine learning pipeline completed!")
EOF

podman run -v ./ml-example.py:/home/appuser/ml-example.py:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/ml-example.py
```

## 🎯 Best Practices

### Performance Optimization
```bash
# Use memory-efficient data types
cat > ./optimized-example.py << 'EOF'
import pandas as pd
import numpy as np

def memory_optimization_example():
    """Example of memory optimization techniques"""
    
    # Generate large dataset
    data = pd.DataFrame({
        'id': range(1_000_000),
        'category': np.random.choice(['A', 'B', 'C', 'D'], 1_000_000),
        'value': np.random.uniform(0, 1000, 1_000_000),
        'flag': np.random.choice([True, False], 1_000_000),
        'date': pd.date_range('2020-01-01', periods=1_000_000, freq='H')
    })
    
    print(f"📊 Original memory usage: {data.memory_usage().sum() / 1024 / 1024:.2f} MB")
    
    # Optimize data types
    data['id'] = data['id'].astype('int32')  # from int64
    data['category'] = data['category'].astype('category')  # from object
    data['value'] = data['value'].astype('float32')  # from float64
    data['flag'] = data['flag'].astype('bool')  # from object
    data['date'] = pd.to_datetime(data['date'])  # ensure datetime
    
    print(f"✅ Optimized memory usage: {data.memory_usage().sum() / 1024 / 1024:.2f} MB")
    print(f"🚀 Memory reduction: {((100 - data.memory_usage().sum() / 1_000_000 / 100 * 1_000_000 / data.memory_usage(deep=True).sum() * 100)):.1f}%")
    
    return data

if __name__ == "__main__":
    optimized_data = memory_optimization_example()
    print("🎯 Memory optimization complete!")
EOF

podman run -v ./optimized-example.py:/home/appuser/optimized-example.py:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/optimized-example.py
```

## 🔧 Error Handling Examples

### Robust Error Handling
```bash
cat > ./error-handling.py << 'EOF'
import pandas as pd
import oracledb
import logging
from datetime import datetime
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class RobustDataProcessor:
    """Example class with robust error handling"""
    
    def __init__(self):
        self.setup_logging()
        self.validate_environment()
    
    def setup_logging(self):
        """Setup comprehensive logging"""
        logger.info("🔧 Setting up logging...")
    
    def validate_environment(self):
        """Validate container environment"""
        try:
            import pandas as pd
            import numpy as np
            logger.info("✅ Python packages validated")
            
            # Check Oracle client
            oracle_path = os.environ.get('ORACLE_INSTANTCLIENT_PATH')
            if oracle_path:
                logger.info("✅ Oracle client path configured")
            else:
                logger.warning("⚠️ Oracle client path not configured")
                
        except ImportError as e:
            logger.error(f"❌ Package import failed: {e}")
            sys.exit(1)
    
    def safe_data_operation(self):
        """Safe data operation with error handling"""
        try:
            # Simulate data processing
            data = pd.DataFrame({
                'id': range(100),
                'value': np.random.randn(100)
            })
            
            # Potential division by zero
            avg_value = data['value'].sum() / len(data)
            normalized_values = data['value'] / avg_value
            
            logger.info(f"✅ Data processed successfully: {len(data)} records")
            return normalized_values
            
        except ZeroDivisionError:
            logger.error("❌ Division by zero in data processing")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error in data processing: {e}")
            return None
    
    def safe_database_operation(self):
        """Safe database operation with retry logic"""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                # Simulate database operation
                if attempt < 2:
                    raise ConnectionError("Simulated connection failure")
                
                logger.info("✅ Database operation successful")
                return True
                
            except ConnectionError as e:
                logger.warning(f"⚠️ Database connection failed (attempt {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    continue
                else:
                    logger.error("❌ All database connection attempts failed")
                    return False
    
    def run_complete_workflow(self):
        """Run complete workflow with comprehensive error handling"""
        logger.info("🚀 Starting robust workflow...")
        
        # Safe data operation
        result = self.safe_data_operation()
        if result is not None:
            logger.info("✅ Data operation completed")
        else:
            logger.error("❌ Data operation failed")
        
        # Safe database operation
        db_success = self.safe_database_operation()
        if db_success:
            logger.info("✅ Database operation completed")
        else:
            logger.error("❌ Database operation failed")
        
        logger.info("🎉 Workflow completed with comprehensive error handling")

# Run the robust example
if __name__ == "__main__":
    processor = RobustDataProcessor()
    processor.run_complete_workflow()
EOF

podman run -v ./error-handling.py:/home/appuser/error-handling.py:Z \
           -it offline-python-runtime:latest \
           python /home/appuser/error-handling.py
```

## 🎉 Conclusion

These examples demonstrate the versatility of the Offline Python Runtime Docker container:

- **📊 Data Science**: From basic analysis to complex analytics with DuckDB
- **🗄️ Database Connectivity**: Oracle integration with enterprise features
- **🔄 ETL Pipelines**: Complete extract-transform-load workflows
- **🌐 Web Applications**: Flask applications with data processing
- **🤖 Machine Learning**: Scikit-learn model training and evaluation
- **🎯 Best Practices**: Memory optimization and error handling

## 📚 Next Steps

- **Configure for your environment**: See [Configuration](configuration.md)
- **Deploy to production**: Follow [Enterprise Deployment](enterprise-deployment.md)
- **Troubleshoot issues**: Reference [Troubleshooting](troubleshooting.md)
- **Contribute to project**: Check [Development Setup](../developer/setup.md)

---

**🚀 Ready to build something amazing?** Start with these examples and adapt them for your specific use case!