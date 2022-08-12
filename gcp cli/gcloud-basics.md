# GCloud Basics

## Log in to gcp

Need to add the --no-launch-browser flag on some workstations because gcloud cannot always find a browser for some reason.

```bash
gcloud auth login --no-launch-browser
```

## Kubernetes Enging

### List clusters

List all clusters in a project. 

```bash
gcloud container clusters list
```

