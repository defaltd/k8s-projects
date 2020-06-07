- [Adding a local image registry](#adding-a-local-image-registry)

## Adding a local image registry

K8s can easily download public images but private images or even local testing requires being able to deploy images into a registry that the K8s cluster has access to. Below is how to setup a local registry using minikube addons:

```
# First, modify your local Docker to allow an insecure registry
# The address should be port 5000 on your Minikube cluster

minikube addon enable registry
```

Then modify your `/etc/hosts` file to include the following:

```
# Minikube Cluster
192.168.99.102  dev.local
```

Now you can use `localhost:5000` in your pod templates for pulling images are deploying your images there.
