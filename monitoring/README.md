# Project 4: Observability Stack

This directory contains the monitoring and observability assets deployed alongside the application.

## Contents

- `prometheus-values.yaml` – Opinionated Helm values used when installing `kube-prometheus-stack`.
- `loki/` – Loki Helm values for single-binary deployment with self-monitoring enabled.
- `prometheus/rules/alert-rules.yaml` – Custom alerting rules for application and infrastructure health.
- `prometheus/servicemonitor.yaml` – ServiceMonitor that wires Prometheus to scrape the application service.
- `grafana/dashboards/` – Curated Grafana dashboards automatically loaded via sidecar.

## Usage

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml --namespace monitoring --create-namespace

# Apply additional manifests
kubectl apply -f prometheus/rules/alert-rules.yaml
kubectl apply -f prometheus/servicemonitor.yaml
```

## Dashboards

Dashboards are labeled with `grafana_dashboard` so the Grafana sidecar automatically loads them. After deployment they appear in the **Kubernetes** folder in Grafana.
