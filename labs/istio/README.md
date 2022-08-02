# Istio

```bash
istioctl manifest apply -f istio-config.yaml
kubectl label namespace <NS> istio-injection=enabled
```
