# GKE - Google Kubernetes Engine

![3.4.0](https://img.shields.io/badge/Datadog%20chart-3.40-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.40.1](https://img.shields.io/badge/Agent-7.40.1-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)

:warning: In a GKE Private Cluster, you must have a Firewall Rule to allow for the control plane to access the Cluster Agent on port 8000.

You will receive an error `Timeout: request did not complete within requested timeout - context deadline exceeded` when trying to deploy a pod if Datadog's admission controller is enabled and the control plane cannot reach the Cluster Agent.

The reason is that the admission controller service handling incoming connections receives the request on port 443 and directs it to a service implemented by the Cluster Agent on port 8000.

By default, in the Network for the cluster there should be a Firewall Rule named like gke-<CLUSTER_NAME>-master. The “Source filters” of the rule match the “Control plane address range” of the cluster. Edit this Firewall Rule to allow ingress to the TCP port 8000.