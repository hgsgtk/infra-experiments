#!/bin/bash

# Kube State Metrics Verification Script
# This script verifies that kube-state-metrics is working correctly

set -e

echo "🔍 Verifying kube-state-metrics installation..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

echo "✅ Connected to Kubernetes cluster: $(kubectl config current-context)"

# Check if namespace exists
if ! kubectl get namespace kube-state-metrics &> /dev/null; then
    echo "❌ kube-state-metrics namespace not found. Please install kube-state-metrics first."
    exit 1
fi

echo "📊 Checking kube-state-metrics resources..."

# Check deployment status
echo "🔍 Deployment status:"
kubectl get deployment kube-state-metrics -n kube-state-metrics

# Check pod status
echo ""
echo "🔍 Pod status:"
kubectl get pods -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics

# Check service status
echo ""
echo "🔍 Service status:"
kubectl get svc -n kube-state-metrics

# Check if pods are ready
echo ""
echo "🔍 Checking pod readiness..."
READY_PODS=$(kubectl get pods -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics --no-headers | grep -c "Running\|Completed" || echo "0")
TOTAL_PODS=$(kubectl get pods -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics --no-headers | wc -l || echo "0")

if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    echo "✅ All pods are ready ($READY_PODS/$TOTAL_PODS)"
else
    echo "❌ Not all pods are ready ($READY_PODS/$TOTAL_PODS)"
    echo "🔍 Checking pod details..."
    kubectl describe pods -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics
    exit 1
fi

# Check metrics endpoint
echo ""
echo "🔍 Testing metrics endpoint..."
POD_NAME=$(kubectl get pods -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics --no-headers | head -1 | awk '{print $1}')

if [ -n "$POD_NAME" ]; then
    echo "📊 Testing metrics endpoint on pod: $POD_NAME"
    
    # Test metrics endpoint
    if kubectl exec -n kube-state-metrics "$POD_NAME" -- wget -qO- --timeout=10 http://localhost:8080/metrics | head -5 > /dev/null 2>&1; then
        echo "✅ Metrics endpoint is accessible"
    else
        echo "❌ Metrics endpoint is not accessible"
        exit 1
    fi
    
    # Test telemetry endpoint
    if kubectl exec -n kube-state-metrics "$POD_NAME" -- wget -qO- --timeout=10 http://localhost:8081/metrics | head -5 > /dev/null 2>&1; then
        echo "✅ Telemetry endpoint is accessible"
    else
        echo "❌ Telemetry endpoint is not accessible"
        exit 1
    fi
    
    # Test health endpoints
    if kubectl exec -n kube-state-metrics "$POD_NAME" -- wget -qO- --timeout=10 http://localhost:8080/healthz | grep -q "ok" 2>/dev/null; then
        echo "✅ Health endpoint is accessible"
    else
        echo "❌ Health endpoint is not accessible"
    fi
else
    echo "❌ No pods found to test endpoints"
    exit 1
fi

# Check RBAC
echo ""
echo "🔍 Checking RBAC permissions..."
if kubectl auth can-i list pods --as=system:serviceaccount:kube-state-metrics:kube-state-metrics -n kube-state-metrics 2>/dev/null | grep -q "yes"; then
    echo "✅ Service account has proper permissions"
else
    echo "❌ Service account may not have proper permissions"
fi

# Check ServiceMonitor if Prometheus Operator is available
if kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null; then
    echo ""
    echo "🔍 Checking ServiceMonitor..."
    if kubectl get servicemonitor kube-state-metrics -n kube-state-metrics &> /dev/null; then
        echo "✅ ServiceMonitor is configured"
    else
        echo "⚠️  ServiceMonitor not found (this is optional)"
    fi
fi

echo ""
echo "🎉 kube-state-metrics verification completed successfully!"
echo ""
echo "📚 To access metrics from outside the cluster:"
echo "   kubectl port-forward -n kube-state-metrics svc/kube-state-metrics 8080:8080"
echo "   curl http://localhost:8080/metrics"
echo ""
echo "🔍 To view logs:"
echo "   kubectl logs -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics"
