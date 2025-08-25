# Kubernetes Cron Jobs

This directory contains the cron jobs for the Kubernetes cluster.

## Files

- `cronjob.yaml` - A sample CronJob that runs every minute and prints the current time
- `broken_cronjob.yaml` - A deliberately broken CronJob for testing failure scenarios

## Sample CronJob

The `cronjob.yaml` file defines a CronJob with the following features:

- **Schedule**: Runs every minute (`*/1 * * * *`)
- **Container**: Uses `busybox:1.35` for lightweight execution
- **Output**: Prints current time, job start time, pod name, and namespace
- **Concurrency**: Prevents overlapping executions (`concurrencyPolicy: Forbid`)
- **History**: Keeps last 3 successful jobs and last 1 failed job
- **Resources**: 
  - CPU: 500m request
  - Memory: 2Gi request
  - Ephemeral Storage: 1Gi request/limit

## Broken CronJob

The `broken_cronjob.yaml` file defines a CronJob that is intentionally designed to fail for testing purposes:

- **Schedule**: Runs every 5 minutes (`*/5 * * * *`)
- **Purpose**: Testing failure scenarios, monitoring systems, and error handling workflows
- **Failure Points**:
  - Non-existent Docker image: `nonexistent-registry.example.com/broken-image:latest`
  - Missing image pull secret: `nonexistent-secret`
  - Missing service account: `nonexistent-serviceaccount`
- **Configuration**:
  - Prevents concurrent executions (`concurrencyPolicy: Forbid`)
  - Keeps only 3 failed job histories for debugging
  - Sets resource limits and requests
  - Uses `restartPolicy: Never` to prevent infinite restart loops

## Usage

### Deploy the CronJob

```bash
# Deploy the working sample cronjob
kubectl apply -f cronjob.yaml

# Deploy the broken cronjob for testing
kubectl apply -f broken_cronjob.yaml
```

### Monitor the CronJob

```bash
# Check CronJob status
kubectl get cronjobs

# List all Jobs created by the CronJob
kubectl get jobs

# View logs from a specific Job
kubectl logs job/sample-cronjob-<timestamp>

# Watch Jobs being created
kubectl get jobs -w

# Check for failed jobs from broken cronjob
kubectl get jobs -l app=broken-cronjob
```

### Delete the CronJob

```bash
# Delete the working cronjob
kubectl delete -f cronjob.yaml

# Delete the broken cronjob
kubectl delete -f broken_cronjob.yaml
```

## Customization

You can modify the `cronjob.yaml` file to:

- Change the schedule using standard cron syntax
- Update the container image
- Modify resource limits and requests
- Add environment variables or volumes
- Change the concurrency policy or job history limits

## Testing Failure Scenarios

The `broken_cronjob.yaml` is useful for:

- Testing monitoring and alerting systems
- Validating error handling workflows
- Simulating infrastructure failures
- Testing job cleanup and retry mechanisms
- Demonstrating Kubernetes failure modes
