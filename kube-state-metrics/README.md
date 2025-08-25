# Kube State Metrics

This project deploys [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) to your Kubernetes cluster. Kube-state-metrics is a service that listens to the Kubernetes API server and generates metrics about the state of the objects.

## What is Kube State Metrics?

Kube-state-metrics is an add-on agent that generates and exposes cluster-level metrics. It is not a replacement for the Kubernetes metrics server. Instead, it is focused on generating metrics from various Kubernetes API objects.

## Features

- **Comprehensive Metrics**: Exposes metrics for pods, nodes, services, deployments, and many other Kubernetes resources
- **Prometheus Integration**: Designed to work seamlessly with Prometheus monitoring
- **Security**: Runs with minimal privileges and follows security best practices
- **Health Checks**: Includes proper liveness, readiness, and startup probes
- **Resource Management**: Configurable resource limits and requests

## Architecture

The deployment consists of:

- **Namespace**: `kube-state-metrics` for isolation
- **Service Account**: With appropriate RBAC permissions
- **Deployment**: Single replica of kube-state-metrics
- **Service**: Exposes metrics on port 8080 and telemetry on port 8081
- **ServiceMonitor**: For Prometheus Operator integration

## Metrics Endpoints

- **Main Metrics**: `/metrics` on port 8080 (for Prometheus scraping)
- **Telemetry**: `/metrics` on port 8081 (for self-monitoring)
- **Health**: `/healthz`, `/livez`, `/readyz` for health checks

## Installation

### Prerequisites

- Kubernetes cluster (1.8+)
- kubectl configured to communicate with your cluster
- Optional: Prometheus Operator for ServiceMonitor support

### Quick Install

```bash
# Apply all resources
kubectl apply -k .

# Or apply individually
kubectl apply -f namespace.yaml
kubectl apply -f service-account.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f servicemonitor.yaml  # Only if using Prometheus Operator
```

### Verify Installation

```bash
# Check if pods are running
kubectl get pods -n kube-state-metrics

# Check service
kubectl get svc -n kube-state-metrics

# Check metrics endpoint
kubectl port-forward -n kube-state-metrics svc/kube-state-metrics 8080:8080
curl http://localhost:8080/metrics
```

## Configuration

### Resource Selection

The deployment is configured to expose metrics for all major Kubernetes resources. You can customize this by modifying the `--resources` argument in the deployment:

```yaml
args:
- --resources=pods,nodes,services,deployments,replicasets,statefulsets
```

### Scaling

To scale the deployment:

```bash
kubectl scale deployment kube-state-metrics --replicas=3 -n kube-state-metrics
```

### Resource Limits

Resource limits and requests can be adjusted in the deployment:

```yaml
resources:
  limits:
    cpu: 200m
    memory: 300Mi
  requests:
    cpu: 100m
    memory: 150Mi
```

## Monitoring

### Prometheus Configuration

If you're using Prometheus, add this scrape config:

```yaml
scrape_configs:
- job_name: 'kube-state-metrics'
  static_configs:
  - targets: ['kube-state-metrics.kube-state-metrics.svc.cluster.local:8080']
```

### Grafana Dashboards

Use the official kube-state-metrics dashboards or create custom ones based on the available metrics.

## Troubleshooting

### Check Pod Status

```bash
kubectl describe pod -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics
```

### Check Logs

```bash
kubectl logs -n kube-state-metrics -l app.kubernetes.io/name=kube-state-metrics
```

### Check RBAC

```bash
kubectl auth can-i list pods --as=system:serviceaccount:kube-state-metrics:kube-state-metrics
```

### Common Issues

1. **Permission Denied**: Ensure the service account has proper RBAC permissions
2. **Metrics Not Scraped**: Check Prometheus configuration and service annotations
3. **High Resource Usage**: Adjust resource limits or reduce the number of monitored resources

## Security

- Runs as non-root user (UID 65534)
- Read-only root filesystem
- No privilege escalation
- Minimal RBAC permissions
- Network policies can be applied for additional security

## Upgrading

To upgrade to a newer version:

1. Update the image tag in `deployment.yaml`
2. Update the version labels in all files
3. Apply the changes: `kubectl apply -k .`

## Contributing

This project follows the same contribution guidelines as the main kube-state-metrics project. See [CONTRIBUTING.md](https://github.com/kubernetes/kube-state-metrics/blob/main/CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## References

- [Official Repository](https://github.com/kubernetes/kube-state-metrics)
- [Kubernetes Documentation](https://kubernetes.io/docs/concepts/cluster-administration/kube-state-metrics/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
