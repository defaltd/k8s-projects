# Pod Basics

## Preparation

This setup focuses on using `minikube` and the `registry` addon. Setting up your local environment to be able to push to the `minikube` registry can be found [here](https://minikube.sigs.k8s.io/docs/handbook/registry/).

## Explanation

The infrastructure of this sample is quite... simple. We have a Pod and a Service object. The Pod is in charge of running the containers you specify. In this example, we have a simple hello world app written in Golang (`./main.go`).

The Service object handles routing traffic to the Pod. This is done by describing in the config how the k8s API can find the pod. For this, we use the selector and a corresponding label that matches our pod(s).

However, this setup is not production ready. If the pod were to suddenly be swarmed with requests, it could die. At the same time, requests aren't being load-balanced and our redundancy of the service does not exist. For this, we need deployments!

## Deployment

* Apply the configs using `kubectl apply -f ./`
* This will spin up a pod for the Hello-World app in Golang + run a network service router (gosay-service:80)
* Run the `kubectl proxy` to be able to navigate to a ClusterIP service from the browser
* View the results at `http://localhost:8001/api/v1/namespaces/default/services/gosay-service:80/proxy/`
