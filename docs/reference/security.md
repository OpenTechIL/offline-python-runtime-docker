# 🔒 Security

This document covers security features, compliance considerations, and best practices for Offline Python Runtime Docker in enterprise environments.

## 🛡️ Security Architecture Overview

### Defense-in-Depth Strategy
```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                        │
├─────────────────────────────────────────────────────────────┤
│  Application Security                                   │
│  ├── Input Validation                                  │
│  ├── SQL Injection Prevention                          │
│  ├── Authentication & Authorization                    │
│  └── Secure Configuration Management                   │
├─────────────────────────────────────────────────────────────┤
│  Container Security                                   │
│  ├── Non-root User (UID/GID 1000)                  │
│  ├── Read-only Filesystem (where possible)             │
│  ├── Capability Dropping                              │
│  ├── SELinux Context Support                          │
│  └── Minimal Attack Surface                           │
├─────────────────────────────────────────────────────────────┤
│  Network Security                                    │
│  ├── Air-gapped Deployment Support                    │
│  ├── Private Registry Integration                     │
│  ├── Network Policy Enforcement                       │
│  └── Secure Communication Protocols                  │
├─────────────────────────────────────────────────────────────┤
│  Data Security                                      │
│  ├── Encryption at Rest                              │
│  ├── Encryption in Transit                          │
│  ├── Data Masking & Anonymization                  │
│  └── Audit Logging                                 │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Container Security Features

### Non-Root User Execution
```yaml
# Security Context Configuration
securityContext:
  runAsNonRoot: true
  runAsUser: 1000          # appuser
  runAsGroup: 1000         # appuser
  fsGroup: 1000            # Filesystem group
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop:
    - ALL  # Drop all capabilities
    add:
    - CHOWN
    - SETGID
    - SETUID
```

### Capability Management
```bash
# Container with minimal capabilities
podman run -it \
           --cap-drop=ALL \
           --cap-add=CHOWN \
           --cap-add=SETGID \
           --cap-add=SETUID \
           --security-opt no-new-privileges:true \
           offline-python-runtime:latest
```

### SELinux Integration
```bash
# SELinux-aware volume mounting
podman run -it \
           -v ./source:/home/appuser/source:Z \
           -v ./data:/home/appuser/data:Z \
           --security-opt label=user:container_runtime_t \
           offline-python-runtime:latest

# Check SELinux context
podman inspect offline-python-runtime | jq '.[0].ProcessLabel.SELinuxLabel'
```

### Read-Only Filesystem
```bash
# Read-only deployment with specific writable paths
podman run -d \
           --read-only \
           --tmpfs /tmp \
           --tmpfs /home/appuser/.cache \
           --tmpfs /home/appuser/tmp \
           -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           offline-python-runtime:latest
```

## 🔑 Authentication & Authorization

### Environment Variable Security
```python
# Secure Configuration Management
class SecureConfig:
    """Secure configuration management"""
    
    def __init__(self):
        self.config = self._load_secure_config()
        self._validate_config()
    
    def _load_secure_config(self):
        """Load configuration from secure sources"""
        import os
        from cryptography.fernet import Fernet
        
        # Priority order for configuration sources
        config_sources = [
            os.environ,           # Environment variables (highest priority)
            self._load_env_file,   # .env file
            self._load_secrets     # Secret management
        ]
        
        config = {}
        for source in config_sources:
            try:
                if callable(source):
                    source_config = source()
                    config.update(source_config)
                else:
                    config.update(source)
            except Exception as e:
                print(f"Warning: Failed to load config source: {e}")
        
        return config
    
    def _load_env_file(self):
        """Load configuration from .env file"""
        from pathlib import Path
        from dotenv import load_dotenv
        
        env_file = Path('/home/appuser/config/.env')
        if env_file.exists():
            load_dotenv(env_file)
            return dict(os.environ)
        return {}
    
    def _load_secrets(self):
        """Load secrets from secure storage"""
        import os
        
        # Example: HashiCorp Vault
        if os.environ.get('VAULT_ADDR'):
            return self._load_from_vault()
        
        # Example: Kubernetes Secrets
        if os.path.exists('/var/run/secrets'):
            return self._load_from_k8s_secrets()
        
        return {}
    
    def _validate_config(self):
        """Validate configuration parameters"""
        required_fields = ['ORACLE_USER', 'ORACLE_PASSWORD', 'ORACLE_DSN']
        
        for field in required_fields:
            if not self.config.get(field):
                raise ValueError(f"Required configuration field missing: {field}")
        
        # Validate Oracle DSN format
        dsn = self.config['ORACLE_DSN']
        if ':' not in dsn or '/' not in dsn:
            raise ValueError(f"Invalid Oracle DSN format: {dsn}")
```

### Token-Based Authentication
```python
# JWT Authentication Implementation
import jwt
import datetime
from functools import wraps
from flask import request, jsonify

class JWTManager:
    """JWT-based authentication manager"""
    
    def __init__(self, secret_key):
        self.secret_key = secret_key
        self.algorithm = 'HS256'
        self.token_expiry = datetime.timedelta(hours=24)
    
    def generate_token(self, user_id, permissions=None):
        """Generate JWT token"""
        payload = {
            'user_id': user_id,
            'permissions': permissions or [],
            'iat': datetime.datetime.utcnow(),
            'exp': datetime.datetime.utcnow() + self.token_expiry
        }
        
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def verify_token(self, token):
        """Verify JWT token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
    
    def require_auth(self, permissions=None):
        """Decorator for protected endpoints"""
        def decorator(f):
            @wraps(f)
            def decorated(*args, **kwargs):
                token = request.headers.get('Authorization', '').replace('Bearer ', '')
                
                payload = self.verify_token(token)
                if not payload:
                    return jsonify({'error': 'Invalid or expired token'}), 401
                
                if permissions and not any(perm in payload['permissions'] for perm in permissions):
                    return jsonify({'error': 'Insufficient permissions'}), 403
                
                return f(*args, **kwargs)
            return decorated
        return decorator
```

## 🔒 Data Protection

### Encryption at Rest
```python
# Data Encryption Implementation
from cryptography.fernet import Fernet
import os
import base64

class DataEncryption:
    """Data encryption and decryption utilities"""
    
    def __init__(self, key=None):
        self.key = key or self._generate_key()
        self.cipher = Fernet(self.key)
    
    def _generate_key(self):
        """Generate encryption key"""
        return Fernet.generate_key()
    
    def encrypt_data(self, data):
        """Encrypt data"""
        if isinstance(data, str):
            data = data.encode()
        
        encrypted = self.cipher.encrypt(data)
        return base64.b64encode(encrypted).decode()
    
    def decrypt_data(self, encrypted_data):
        """Decrypt data"""
        encrypted_bytes = base64.b64decode(encrypted_data.encode())
        decrypted = self.cipher.decrypt(encrypted_bytes)
        return decrypted.decode()
    
    def encrypt_file(self, file_path):
        """Encrypt file contents"""
        with open(file_path, 'rb') as f:
            data = f.read()
        
        encrypted = self.cipher.encrypt(data)
        
        with open(f"{file_path}.enc", 'wb') as f:
            f.write(encrypted)
    
    def decrypt_file(self, encrypted_file_path):
        """Decrypt file contents"""
        with open(encrypted_file_path, 'rb') as f:
            encrypted_data = f.read()
        
        decrypted = self.cipher.decrypt(encrypted_data)
        
        # Remove .enc extension
        output_path = encrypted_file_path.replace('.enc', '')
        with open(output_path, 'wb') as f:
            f.write(decrypted)
```

### Sensitive Data Masking
```python
# Data Masking Implementation
import re
import hashlib

class DataMasker:
    """Sensitive data masking utilities"""
    
    @staticmethod
    def mask_email(email):
        """Mask email addresses"""
        if not email or '@' not in email:
            return email
        
        local, domain = email.split('@', 1)
        if len(local) > 2:
            masked_local = local[0] + '*' * (len(local) - 2)
        else:
            masked_local = '*' * len(local)
        
        return f"{masked_local}@{domain}"
    
    @staticmethod
    def mask_phone(phone):
        """Mask phone numbers"""
        if not phone:
            return phone
        
        # Remove non-digits
        digits = re.sub(r'\D', '', phone)
        
        if len(digits) >= 4:
            return digits[:-4] + '*' * 4
        else:
            return '*' * len(digits)
    
    @staticmethod
    def mask_credit_card(card_number):
        """Mask credit card numbers"""
        if not card_number:
            return card_number
        
        # Remove spaces and dashes
        digits = re.sub(r'\D', '', card_number)
        
        if len(digits) >= 4:
            return '****-****-****-' + digits[-4]
        else:
            return '*' * len(digits)
    
    @staticmethod
    def hash_sensitive_data(data, salt=None):
        """Hash sensitive data for comparison"""
        salt = salt or os.urandom(32)
        
        return hashlib.pbkdf2_hmac(
            'sha256',
            data.encode(),
            salt,
            100000  # iterations
        ).hex()
```

## 📊 Audit & Compliance

### Audit Logging
```python
# Comprehensive Audit Logging
import logging
import json
import datetime
import os

class AuditLogger:
    """Enterprise audit logging system"""
    
    def __init__(self, log_file='/home/appuser/logs/audit.log'):
        self.log_file = log_file
        self.logger = self._setup_audit_logger()
    
    def _setup_audit_logger(self):
        """Setup audit logger with structured logging"""
        logger = logging.getLogger('audit')
        logger.setLevel(logging.INFO)
        
        # Create file handler
        handler = logging.FileHandler(self.log_file)
        handler.setLevel(logging.INFO)
        
        # JSON formatter for structured logging
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        
        logger.addHandler(handler)
        return logger
    
    def log_access(self, user, resource, action, result='success', details=None):
        """Log access attempts"""
        audit_record = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event_type': 'access',
            'user': user,
            'resource': resource,
            'action': action,
            'result': result,
            'details': details or {},
            'source_ip': self._get_source_ip(),
            'user_agent': self._get_user_agent(),
            'session_id': self._get_session_id()
        }
        
        self.logger.info(json.dumps(audit_record))
    
    def log_data_access(self, user, table, query, rows_affected):
        """Log database data access"""
        audit_record = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event_type': 'data_access',
            'user': user,
            'table': table,
            'query': query,
            'rows_affected': rows_affected,
            'compliance_flags': self._check_compliance_flags(query)
        }
        
        self.logger.info(json.dumps(audit_record))
    
    def log_security_event(self, event_type, severity, details):
        """Log security events"""
        audit_record = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event_type': 'security',
            'security_event': event_type,
            'severity': severity,  # low, medium, high, critical
            'details': details,
            'container_id': os.environ.get('HOSTNAME'),
            'source': 'offline-python-runtime'
        }
        
        self.logger.info(json.dumps(audit_record))
        
        # High severity events trigger immediate alerts
        if severity in ['high', 'critical']:
            self._trigger_security_alert(audit_record)
```

### Compliance Framework
```python
# Compliance Checking
class ComplianceChecker:
    """Enterprise compliance validation"""
    
    def __init__(self):
        self.compliance_rules = self._load_compliance_rules()
    
    def check_gdpr_compliance(self, user_data):
        """Check GDPR compliance"""
        violations = []
        
        # Check for personal data encryption
        if not self._is_encrypted(user_data.get('personal_info')):
            violations.append('Personal data not encrypted')
        
        # Check for consent management
        if not user_data.get('consent_recorded'):
            violations.append('User consent not recorded')
        
        # Check for data retention policies
        if not self._check_retention_policy(user_data):
            violations.append('Data retention policy violation')
        
        return {
            'compliant': len(violations) == 0,
            'violations': violations,
            'framework': 'GDPR'
        }
    
    def check_pci_dss_compliance(self, payment_data):
        """Check PCI DSS compliance"""
        violations = []
        
        # Check for credit card encryption
        if not self._is_encrypted(payment_data.get('card_number')):
            violations.append('Credit card data not encrypted')
        
        # Check for secure transmission
        if not payment_data.get('secure_transmission'):
            violations.append('Payment data not transmitted securely')
        
        # Check for access logging
        if not payment_data.get('access_logged'):
            violations.append('Payment data access not logged')
        
        return {
            'compliant': len(violations) == 0,
            'violations': violations,
            'framework': 'PCI_DSS'
        }
    
    def check_hipaa_compliance(self, health_data):
        """Check HIPAA compliance"""
        violations = []
        
        # Check for PHI encryption
        if not self._is_encrypted(health_data.get('phi')):
            violations.append('Protected health information not encrypted')
        
        # Check for access controls
        if not health_data.get('access_controls'):
            violations.append('Insufficient access controls for PHI')
        
        # Check for audit logging
        if not health_data.get('audit_trail'):
            violations.append('PHI access not audited')
        
        return {
            'compliant': len(violations) == 0,
            'violations': violations,
            'framework': 'HIPAA'
        }
```

## 🚨 Security Monitoring

### Intrusion Detection
```python
# Security Event Monitoring
import re
import time
from collections import defaultdict, deque

class SecurityMonitor:
    """Real-time security monitoring"""
    
    def __init__(self):
        self.event_history = deque(maxlen=1000)
        self.ip_counts = defaultdict(int)
        self.failed_logins = defaultdict(int)
        self.suspicious_patterns = self._load_suspicious_patterns()
    
    def detect_sql_injection(self, input_data):
        """Detect SQL injection attempts"""
        sql_patterns = [
            r"union\s+select",
            r"drop\s+table",
            r"insert\s+into",
            r"delete\s+from",
            r"exec\s*\(",
            r"script\s*>",
            r"alert\s*\(",
            r"onerror\s*="
        ]
        
        input_lower = input_data.lower()
        
        for pattern in sql_patterns:
            if re.search(pattern, input_lower):
                return True, f"SQL injection pattern detected: {pattern}"
        
        return False, None
    
    def detect_xss(self, input_data):
        """Detect XSS attempts"""
        xss_patterns = [
            r"<script[^>]*>",
            r"javascript:",
            r"onload\s*=",
            r"onerror\s*=",
            r"onclick\s*=",
            r"<iframe",
            r"document\.cookie",
            r"window\.location"
        ]
        
        for pattern in xss_patterns:
            if re.search(pattern, input_data, re.IGNORECASE):
                return True, f"XSS pattern detected: {pattern}"
        
        return False, None
    
    def detect_brute_force(self, ip_address, success=False):
        """Detect brute force attacks"""
        current_time = time.time()
        
        if not success:
            self.failed_logins[ip_address] += 1
            
            # Check for threshold violations
            if self.failed_logins[ip_address] > 10:
                return True, "Brute force attack detected: too many failed attempts"
        
        return False, None
    
    def detect_anomalous_access(self, user_id, resource, time_of_access):
        """Detect anomalous access patterns"""
        # Store access patterns
        self.event_history.append({
            'user': user_id,
            'resource': resource,
            'time': time_of_access
        })
        
        # Check for unusual access times (2 AM - 4 AM)
        access_hour = time_of_access.hour
        if 2 <= access_hour <= 4 and user_id != 'system':
            return True, "Unusual access time detected"
        
        return False, None
    
    def trigger_security_alert(self, alert_type, severity, details):
        """Trigger security alerts"""
        import requests
        
        alert_data = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'alert_type': alert_type,
            'severity': severity,
            'details': details,
            'container_id': os.environ.get('HOSTNAME'),
            'source': 'offline-python-runtime'
        }
        
        # Send to alerting system
        try:
            response = requests.post(
                os.environ.get('SECURITY_WEBHOOK_URL'),
                json=alert_data,
                timeout=5
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Failed to send security alert: {e}")
            return False
```

## 🔧 Security Hardening

### Container Security Scanner
```bash
#!/bin/bash
# Security scanning script
#!/bin/bash

CONTAINER_NAME="offline-python-runtime"
REPORT_FILE="/tmp/security-scan-report.txt"

echo "🔍 Container Security Scan Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Check container configuration
echo "📋 Container Configuration:" >> $REPORT_FILE
podman inspect $CONTAINER_NAME | jq '.[0].Config' >> $REPORT_FILE

# Check security context
echo "" >> $REPORT_FILE
echo "🛡️ Security Context:" >> $REPORT_FILE
podman inspect $CONTAINER_NAME | jq '.[0].HostConfig.SecurityOpt' >> $REPORT_FILE

# Check capabilities
echo "" >> $REPORT_FILE
echo "🔧 Capabilities:" >> $REPORT_FILE
podman inspect $CONTAINER_NAME | jq '.[0].HostConfig.CapCap' >> $REPORT_FILE

# Check user information
echo "" >> $REPORT_FILE
echo "👤 User Information:" >> $REPORT_FILE
podman inspect $CONTAINER_NAME | jq '.[0].Config.User' >> $REPORT_FILE

# Check volume mounts
echo "" >> $REPORT_FILE
echo "📁 Volume Mounts:" >> $REPORT_FILE
podman inspect $CONTAINER_NAME | jq '.[0].Mounts' >> $REPORT_FILE

# Security recommendations
echo "" >> $REPORT_FILE
echo "💡 Security Recommendations:" >> $REPORT_FILE

# Check for privileged mode
if podman inspect $CONTAINER_NAME | jq -r '.[0].HostConfig.Privileged' | grep -q true; then
    echo "❌ Container running in privileged mode - should be false" >> $REPORT_FILE
else
    echo "✅ Container not privileged" >> $REPORT_FILE
fi

# Check for root user
USER_ID=$(podman inspect $CONTAINER_NAME | jq -r '.[0].Config.User // "root"')
if [ "$USER_ID" = "root" ] || [ -z "$USER_ID" ]; then
    echo "❌ Container running as root - should use non-root user" >> $REPORT_FILE
else
    echo "✅ Container running as non-root user ($USER_ID)" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "📊 Scan completed. Review report for security issues." >> $REPORT_FILE

cat $REPORT_FILE
```

## 📋 Security Checklist

### Pre-Deployment Security Checklist
```yaml
# Security Checklist
security_checklist:
  container_security:
    - [ ] Running as non-root user (UID 1000)
    - [ ] No privileged mode
    - [ ] Capabilities dropped (except necessary ones)
    - [ ] Read-only filesystem where possible
    - [ ] SELinux context properly configured
    - [ ] No host network access (unless required)
  
  application_security:
    - [ ] Input validation implemented
    - [ ] SQL injection prevention
    - [ ] XSS protection
    - [ ] Authentication and authorization
    - [ ] Secure session management
    - [ ] Error handling without information leakage
  
  data_security:
    - [ ] Encryption at rest
    - [ ] Encryption in transit
    - [ ] Sensitive data masking
    - [ ] Access logging implemented
    - [ ] Data retention policies
  
  network_security:
    - [ ] Private registry usage
    - [ ] Network policies configured
    - [ ] TLS/SSL communication
    - [ ] Firewall rules applied
    - [ ] VPN access for management
  
  compliance:
    - [ ] GDPR compliance check
    - [ ] PCI DSS compliance check (if applicable)
    - [ ] HIPAA compliance check (if applicable)
    - [ ] Security audit logging
    - [ ] Incident response plan
```

## 📞 Security Support

### Incident Response
1. **Immediate Actions**
   - Isolate affected containers
   - Preserve forensic evidence
   - Notify security team
   - Document all actions taken

2. **Investigation Process**
   - Review audit logs
   - Analyze security events
   - Identify root cause
   - Assess impact scope

3. **Recovery Actions**
   - Patch vulnerabilities
   - Update configurations
   - Restore from backups if needed
   - Implement additional controls

### Security Resources
- **📖 Documentation**: [Configuration Guide](../user/configuration.md)
- **🔍 Testing**: [Security Testing Guide](https://owasp.org/)
- **📊 Monitoring**: [Best Practices](https://cisecurity.org/)
- **🐛 Report Issues**: [Security Issues](https://github.com/opentechil/offline-python-runtime-docker/security)

---

**🔒 Enterprise-grade security built for compliance and peace of mind!**