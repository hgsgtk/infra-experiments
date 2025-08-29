# Argo CD Template Generation

```bash
$ helm repo add argo https://argoproj.github.io/argo-helm
 
$ helm repo update

$ helm template argo-cd argo/argo-cd --output-dir argocd-manifests --set crds.install=false
```

- crds.install=false: https://artifacthub.io/packages/helm/argo/argo-cd#custom-resource-definitions
