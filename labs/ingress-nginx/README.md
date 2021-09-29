# NGINX Ingress Controller

![4.0.3](https://img.shields.io/badge/NGINX%20Ingress%20chart-4.0.3-009539?labelColor=f0f0f0&logo=Helm&logoColor=009539)
![1.0.2](https://img.shields.io/badge/NGINX%20Ingress%20Controller-1.0.2-009539?labelColor=f0f0f0&logo=NGINX&logoColor=009539)

Deploys an NGINX Ingress Controller with [monitoring](https://docs.datadoghq.com/integrations/nginx_ingress_controller) and [APM](https://docs.datadoghq.com/tracing/setup_overview/proxy_setup/?tab=nginx#nginx-ingress-controller-for-kubernetes) enabled. The deployment uses [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) for simplicity.

After deployment the ingress controller will be accessible on ports `30080` and `30443` of any worker node. The (Kubernetes) lab craetes a DNS entry for `cluster` that balances between all worker nodes. e.g.: If you master node is `master.k8s.aws.pipsquack.ca`, you can use `cluster.k8s.aws.pipsquack.ca` to balance across the workers.

Install [NGINX Ingress Helm chart](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx).

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Deploy NGINX Ingress Controller.

```bash
kubectl create ns ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f ingress-nginx-values.yaml
```

[Advanced Config options](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/)
