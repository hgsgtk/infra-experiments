#!/bin/bash

# Kube State Metrics Uninstallation Script
# This script removes kube-state-metrics from your Kubernetes cluster

set -e

echo "🗑️  Uninstalling kube-state-metrics..."

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

# Check if kube-state-metrics namespace exists
if ! kubectl get namespace kube-state-metrics &> /dev/null; then
    echo "⚠️  kube-state-metrics namespace not found. Nothing to uninstall."
    exit 0
fi

echo "📦 Removing kube-state-metrics resources..."

# Determine the correct path to the kube-state-metrics directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBE_STATE_METRICS_DIR="$(dirname "$SCRIPT_DIR")"

# Remove resources using kustomize if available
if command -v kubectl &> /dev/null && kubectl version --client --output=yaml | grep -q "kustomize"; then
    echo "🔧 Using kustomize for removal..."
    kubectl delete -k "$KUBE_STATE_METRICS_DIR/" --ignore-not-found=true
else
    echo "🔧 Removing resources individually..."
    
    # Remove ServiceMonitor first if it exists
    if kubectl get servicemonitor kube-state-metrics -n kube-state-metrics &> /dev/null; then
        kubectl delete servicemonitor kube-state-metrics -n kube-state-metrics --ignore-not-found=true
    fi
    
    # Remove other resources
    kubectl delete -f "$KUBE_STATE_METRICS_DIR/service.yaml" --ignore-not-found=true
    kubectl delete -f "$KUBE_STATE_METRICS_DIR/deployment.yaml" --ignore-not-found=true
    kubectl delete -f "$KUBE_STATE_METRICS_DIR/service-account.yaml" --ignore-not-found=true
    kubectl delete -f "$KUBE_STATE_METRICS_DIR/namespace.yaml" --ignore-not-found=true
fi

echo "⏳ Waiting for resources to be removed..."
kubectl wait --for=delete deployment/kube-state-metrics -n kube-state-metrics --timeout=60s 2>/dev/null || true

echo "✅ kube-state-metrics uninstallation completed!"

# Verify removal
if kubectl get namespace kube-state-metrics &> /dev/null; then
    echo "⚠️  kube-state-metrics namespace still exists. You may need to remove it manually:"
    echo "   kubectl delete namespace kube-state-metrics"
else
    echo "✅ All kube-state-metrics resources have been removed successfully."
fi
