# Project 4 · Observability Stack

This repository packages the monitoring and observability assets for the DevOps journey.

## What's Included

- `monitoring/` – Prometheus, Grafana, Loki, and alerting configuration.
- `prometheus-values.yaml` – Helm values for `kube-prometheus-stack`.
- `scripts/` – Helper automation (`monitoring-smoketest.sh`, `metrics-canary.sh`, `trigger-alerts.sh`).

The `monitoring/README.md` file dives into deployment details.

## Getting Started

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml --namespace monitoring --create-namespace

# Apply extra manifests
kubectl apply -f monitoring/prometheus/rules/alert-rules.yaml
kubectl apply -f monitoring/prometheus/servicemonitor.yaml

# Run a quick smoke test from scripts/
./scripts/monitoring-smoketest.sh monitoring devops-app
```
