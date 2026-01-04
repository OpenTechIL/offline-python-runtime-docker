# 🏢 Enterprise Deployment

This guide covers enterprise deployment strategies for Offline Python Runtime Docker, including air-gapped environments, private registries, Kubernetes deployment, and production best practices.

## 🎯 Enterprise Deployment Scenarios

### 1. Air-Gapped Network Deployment
Complete offline deployment with no external network access.

### 2. Private Registry Deployment
Deploy to internal container registry with security controls.

### 3. Kubernetes Orchestration
Deploy in enterprise Kubernetes clusters with resource management.

### 4. Multi-Environment Setup
Development, staging, and production deployments.

## 🔒 Air-Gapped Deployment

### Step 1: Export Container Image
```bash
# On internet-connected system
podman pull ghcr.io/opentechil/offline-python-runtime-docker:latest

# Export container for air-gapped transfer
podman save -o offline-python-runtime-docker.tar \
           ghcr.io/opentechil/offline-python-runtime-docker:latest

# Verify export file
ls -lh offline-python-runtime-docker.tar
sha256sum offline-python-runtime-docker.tar > offline-python-runtime-docker.sha256
```

### Step 2: Transfer to Air-Gapped Environment
```bash
# Transfer methods (choose based on security requirements)

# Option A: Physical media transfer (sneaker-net)
cp offline-python-runtime-docker.tar /media/usb-stick/
cp offline-python-runtime-docker.sha256 /media/usb-stick/

# Option B: Secure file transfer (if allowed)
scp offline-python-runtime-docker.tar user@air-gapped-server:/tmp/
scp offline-python-runtime-docker.sha256 user@air-gapped-server:/tmp/

# Option C: Internal file transfer system
# Copy to internal network share or secure transfer appliance
```

### Step 3: Load Container in Air-Gapped Environment
```bash
# On air-gapped system
cd /tmp

# Verify integrity
sha256sum -c offline-python-runtime-docker.sha256

# Load container into local registry
podman load -i offline-python-runtime-docker.tar

# Verify loaded image
podman images | grep offline-python-runtime-docker

# Tag for local deployment
podman tag localhost/offline-python-runtime-docker:latest \
       offline-python-runtime:enterprise
```

### Step 4: Deploy Application
```bash
# Create deployment directory
mkdir -p /opt/enterprise-app/{source,data,logs,config}
cd /opt/enterprise-app

# Create application structure
cp /path/to/your/app.py ./source/
cp /path/to/your/requirements.txt ./config/

# Deploy with enterprise configuration
podman run -d \
           --name python-enterprise-app \
           -v ./source:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           -v ./logs:/home/appuser/logs:Z \
           -v ./config:/home/appuser/config:Z,ro \
           --env-file ./config/production.env \
           --restart=unless-stopped \
           offline-python-runtime:enterprise
```

## 🏭 Private Registry Deployment

### Setup Private Registry
```bash
# Create registry directory structure
mkdir -p /opt/container-registry/{data,certs,auth}
cd /opt/container-registry

# Generate self-signed certificates (for internal use)
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -x509 -days 365 -out certs/domain.crt -subj "/CN=registry.company.com"

# Create authentication
htpasswd -Bbn registryuser securepassword > auth/htpasswd

# Start secure registry
podman run -d \
  --name secure-registry \
  --restart=unless-stopped \
  -p 5000:5000 \
  -v ./data:/var/lib/registry:Z \
  -v ./certs:/certs:Z \
  -v ./auth:/auth:Z \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  registry:2
```

### Push to Private Registry
```bash
# Tag for private registry
podman tag localhost/offline-python-runtime-docker:latest \
       registry.company.com/offline-python-runtime:enterprise

# Login to private registry
podman login registry.company.com -u registryuser

# Push to private registry
podman push registry.company.com/offline-python-runtime:enterprise

# Verify push
curl -k https://registry.company.com:5000/v2/_catalog
```

### Deploy from Private Registry
```bash
# Pull from private registry
podman pull registry.company.com/offline-python-runtime:enterprise

# Deploy in production environment
podman run -d \
           --name production-app \
           -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           --env-file ./production.env \
           registry.company.com/offline-python-runtime:enterprise
```

## ☸️ Kubernetes Deployment

### Kubernetes Manifest
```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-runtime-deployment
  namespace: enterprise-apps
  labels:
    app: python-runtime
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: python-runtime
  template:
    metadata:
      labels:
        app: python-runtime
        version: v1.0.0
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
      - name: python-runtime
        image: registry.company.com/offline-python-runtime:enterprise
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
          name: http
          protocol: TCP
        env:
        - name: APP_ENV
          value: "production"
        - name: LOG_LEVEL
          value: "INFO"
        - name: TZ
          value: "UTC"
        volumeMounts:
        - name: app-code
          mountPath: /home/appuser/app
          readOnly: true
        - name: app-data
          mountPath: /home/appuser/data
        - name: app-logs
          mountPath: /home/appuser/logs
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
      volumes:
      - name: app-code
        configMap:
          name: python-app-config
      - name: app-data
        persistentVolumeClaim:
          claimName: app-data-pvc
      - name: app-logs
        persistentVolumeClaim:
          claimName: app-logs-pvc
      imagePullSecrets:
      - name: registry-secret
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: python-runtime-service
  namespace: enterprise-apps
  labels:
    app: python-runtime
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8000
    protocol: TCP
    name: http
  selector:
    app: python-runtime
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: python-app-config
  namespace: enterprise-apps
data:
  app.py: |
    import os
    from flask import Flask, jsonify
    import pandas as pd
    import oracledb
    
    app = Flask(__name__)
    
    @app.route('/health')
    def health():
        return jsonify({'status': 'healthy', 'version': '1.0.0'})
    
    @app.route('/ready')
    def ready():
        return jsonify({'status': 'ready'})
    
    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=8000)
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
  namespace: enterprise-apps
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-logs-pvc
  namespace: enterprise-apps
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

### Deploy to Kubernetes
```bash
# Create namespace
kubectl create namespace enterprise-apps

# Create image pull secret
kubectl create secret docker-registry registry-secret \
  --docker-server=registry.company.com \
  --docker-username=registryuser \
  --docker-password=securepassword \
  --namespace=enterprise-apps

# Apply configuration
kubectl apply -f k8s-deployment.yaml

# Monitor deployment
kubectl get pods -n enterprise-apps -w

# Check service
kubectl get svc -n enterprise-apps
kubectl logs -n enterprise-apps -l app=python-runtime --tail=50
```

## 🏭 Production Deployment Patterns

### High Availability Setup
```bash
# Load balancer configuration
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  app:
    image: registry.company.com/offline-python-runtime:enterprise
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          memory: 4G
          cpus: '2'
        reservations:
          memory: 2G
          cpus: '1'
    volumes:
      - ./app:/home/appuser/app:Z,ro
      - ./data:/home/appuser/data:Z
      - app-logs:/home/appuser/logs
    environment:
      - APP_ENV=production
      - LOG_LEVEL=INFO
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    deploy:
      replicas: 2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:Z,ro
      - ./ssl-certs:/etc/ssl/certs:Z,ro
    networks:
      - app-network
    depends_on:
      - app

volumes:
  app-logs:

networks:
  app-network:
    driver: bridge
EOF

# Deploy production stack
docker-compose -f docker-compose.prod.yml up -d
```

### Monitoring and Logging
```bash
# Prometheus monitoring configuration
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'python-runtime'
    static_configs:
      - targets: ['python-runtime-service:80']
    metrics_path: /metrics
    scrape_interval: 30s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
EOF

# Alert rules
cat > alert_rules.yml << 'EOF'
groups:
- name: python-runtime-alerts
  rules:
  - alert: PythonRuntimeDown
    expr: up{job="python-runtime"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Python runtime is down"
      description: "Python runtime has been down for more than 1 minute"

  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 80% for more than 5 minutes"
EOF
```

## 🔐 Security Hardening

### Container Security Configuration
```bash
# Secure container deployment
podman run -d \
           --name secure-python-app \
           --read-only \
           --tmpfs /tmp \
           --tmpfs /home/appuser/.cache \
           --no-new-privileges \
           --user 1000:1000 \
           --cap-drop=ALL \
           --cap-add=CHOWN \
           --cap-add=SETGID \
           --cap-add=SETUID \
           --security-opt no-new-privileges:true \
           --security-opt label=type:container_runtime_t \
           -v ./app:/home/appuser/app:Z,ro \
           -v ./data:/home/appuser/data:Z \
           --env-file ./production.env \
           registry.company.com/offline-python-runtime:enterprise

# Scan container for vulnerabilities
podman run --rm \
           -v /var/run/docker.sock:/var/run/docker.sock:Z \
           aquasec/trivy image registry.company.com/offline-python-runtime:enterprise

# Compliance check
podman run --rm \
           -v ./app:/app:Z \
           openpolicyagent/conftest test ./app/
```

### Network Security
```bash
# Network policy for Kubernetes
cat > network-policy.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: python-runtime-netpol
  namespace: enterprise-apps
spec:
  podSelector:
    matchLabels:
      app: python-runtime
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    ports:
    - protocol: TCP
      port: 1521
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 443
EOF
```

## 📊 Performance Optimization

### Resource Tuning
```bash
# Performance-optimized deployment
podman run -d \
           --name optimized-python-app \
           --memory=8g \
           --memory-swap=8g \
           --cpus=4 \
           --cpu-shares=4096 \
           --ulimit nofile=65536:65536 \
           --shm-size=512m \
           --pids-limit=1024 \
           -v ./app:/home/appuser/app:Z,ro \
           --env-file ./performance.env \
           registry.company.com/offline-python-runtime:enterprise

# Performance monitoring
podman run --rm \
           -v /var/run/docker.sock:/var/run/docker.sock:Z \
           --name performance-monitor \
           -d \
           netdata/netdata
```

## 🔄 Deployment Automation

### CI/CD Pipeline Script
```bash
#!/bin/bash
# deploy-enterprise.sh - Enterprise deployment script

set -euo pipefail

# Configuration
REGISTRY="registry.company.com"
IMAGE_NAME="offline-python-runtime"
VERSION="${1:-latest}"
ENVIRONMENT="${2:-production}"
NAMESPACE="enterprise-apps"

# Functions
build_and_push() {
    echo "🏗️ Building and pushing container..."
    
    # Build image
    podman build . -t ${REGISTRY}/${IMAGE_NAME}:${VERSION}
    
    # Tag for environment
    podman tag ${REGISTRY}/${IMAGE_NAME}:${VERSION} \
           ${REGISTRY}/${IMAGE_NAME}:${ENVIRONMENT}
    
    # Push to registry
    podman push ${REGISTRY}/${IMAGE_NAME}:${VERSION}
    podman push ${REGISTRY}/${IMAGE_NAME}:${ENVIRONMENT}
    
    echo "✅ Container built and pushed successfully"
}

deploy_to_kubernetes() {
    echo "☸️ Deploying to Kubernetes..."
    
    # Update image in deployment
    kubectl set image deployment/python-runtime-deployment \
           python-runtime=${REGISTRY}/${IMAGE_NAME}:${ENVIRONMENT} \
           -n ${NAMESPACE}
    
    # Wait for rollout
    kubectl rollout status deployment/python-runtime-deployment \
           -n ${NAMESPACE} --timeout=300s
    
    echo "✅ Deployment completed successfully"
}

health_check() {
    echo "🏥 Running health check..."
    
    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod \
           -l app=python-runtime -n ${NAMESPACE} --timeout=300s
    
    # Health check
    HEALTH_URL=$(kubectl get svc python-runtime-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if curl -f http://${HEALTH_URL}/health; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed"
        exit 1
    fi
}

# Main execution
main() {
    echo "🚀 Starting enterprise deployment..."
    echo "📦 Version: ${VERSION}"
    echo "🌍 Environment: ${ENVIRONMENT}"
    echo "📊 Namespace: ${NAMESPACE}"
    
    build_and_push
    deploy_to_kubernetes
    health_check
    
    echo "🎉 Enterprise deployment completed successfully!"
}

# Run main function
main "$@"
```

## 📞 Enterprise Support

### Troubleshooting Enterprise Issues
```bash
# Container status check
kubectl get pods -n enterprise-apps -o wide
kubectl describe pod -l app=python-runtime -n enterprise-apps

# Logs investigation
kubectl logs -n enterprise-apps -l app=python-runtime --tail=100

# Resource usage
kubectl top pods -n enterprise-apps
kubectl top nodes

# Network connectivity
kubectl exec -it deployment/python-runtime-deployment -n enterprise-apps -- \
       ping database-service.database.svc.cluster.local
```

### Backup and Recovery
```bash
# Container backup
podman export python-enterprise-app > enterprise-app-backup-$(date +%Y%m%d).tar

# Data backup
kubectl exec -it deployment/python-runtime-deployment -n enterprise-apps -- \
       tar -czf /tmp/data-backup-$(date +%Y%m%d).tar.gz /home/appuser/data

# Copy backup to storage
kubectl cp enterprise-apps/$(kubectl get pods -l app=python-runtime -n enterprise-apps -o jsonpath='{.items[0].metadata.name}'):/tmp/data-backup-$(date +%Y%m%d).tar.gz \
       ./backups/data-backup-$(date +%Y%m%d).tar.gz
```

## 📚 Next Steps

- **📖 Configuration**: [Configuration Guide](configuration.md) for detailed settings
- **💻 Examples**: [Usage Examples](usage-examples.md) for practical implementations
- **🚨 Troubleshooting**: [Troubleshooting Guide](troubleshooting.md) for common issues
- **👨‍💻 Development**: [Development Setup](../developer/setup.md) for contribution

---

**🏢 Ready for enterprise deployment?** Start with air-gapped deployment or private registry setup for secure production deployments!