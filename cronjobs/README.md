# Kubernetes Cron Jobs

This directory contains the cron jobs for the Kubernetes cluster.

## Files

- `cronjob.yaml` - A sample CronJob that runs every minute and prints the current time

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

## Usage

### Deploy the CronJob

```bash
kubectl apply -f cronjob.yaml
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
```

### Delete the CronJob

```bash
kubectl delete -f cronjob.yaml
```

## Customization

You can modify the `cronjob.yaml` file to:

- Change the schedule using standard cron syntax
- Update the container image
- Modify resource limits and requests
- Add environment variables or volumes
- Change the concurrency policy or job history limits
