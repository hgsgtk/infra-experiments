#!/bin/bash

# Kube State Metrics Installation Script
# This script installs kube-state-metrics to your Kubernetes cluster

set -e

echo "🚀 Installing kube-state-metrics..."

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

# Create namespace and apply resources
echo "📦 Creating namespace and applying resources..."

# Determine the correct path to the kube-state-metrics directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBE_STATE_METRICS_DIR="$(dirname "$SCRIPT_DIR")"

# Apply all resources using kustomize
if command -v kubectl &> /dev/null && kubectl version --client --output=yaml | grep -q "kustomize"; then
    echo "🔧 Using kustomize for deployment..."
    kubectl apply -k "$KUBE_STATE_METRICS_DIR/"
else
    echo "🔧 Applying resources individually..."
    kubectl apply -f "$KUBE_STATE_METRICS_DIR/namespace.yaml"
    kubectl apply -f "$KUBE_STATE_METRICS_DIR/service-account.yaml"
    kubectl apply -f "$KUBE_STATE_METRICS_DIR/deployment.yaml"
    kubectl apply -f "$KUBE_STATE_METRICS_DIR/service.yaml"
    
    # Check if Prometheus Operator is available for ServiceMonitor
    if kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null; then
        echo "📊 Prometheus Operator detected, applying ServiceMonitor..."
        kubectl apply -f "$KUBE_STATE_METRICS_DIR/servicemonitor.yaml"
    else
        echo "⚠️  Prometheus Operator not detected, skipping ServiceMonitor"
    fi
fi

echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kube-state-metrics -n kube-state-metrics

echo "✅ kube-state-metrics installation completed!"

# Show status
echo ""
echo "📊 Current status:"
kubectl get pods -n kube-state-metrics
echo ""
kubectl get svc -n kube-state-metrics

echo ""
echo "🔍 To verify the installation:"
echo "   kubectl port-forward -n kube-state-metrics svc/kube-state-metrics 8080:8080"
echo "   curl http://localhost:8080/metrics"
echo ""
echo "📚 For more information, see the README.md file"
