# NGINX Ingress Controller

![0.10.1](https://img.shields.io/badge/NGINX%20Ingress%20chart-0.10.1-009539?labelColor=f0f0f0&logo=Helm&logoColor=009539)
![1.12.1](https://img.shields.io/badge/NGINX%20Ingress%20Controller-1.12.1-009539?labelColor=f0f0f0&logo=Helm&logoColor=009539)

Deploys an NGINX Ingress Controller with [monitoring](https://docs.datadoghq.com/integrations/nginx_ingress_controller) and [APM](https://docs.datadoghq.com/tracing/setup_overview/proxy_setup/?tab=nginx#nginx-ingress-controller-for-kubernetes) enabled. The deployment uses [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) for simplicity. After deployment the ingress controller will be accessible on ports `30080` and `30443`.

Install [NGINX Ingress Helm chart](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx).

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Deploy NGINX Ingress Controller.

```bash
kubectl create ns ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f nginx-values.yaml
```

[Advanced Config options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/)
