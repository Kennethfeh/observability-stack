# Observability Stack (Kubernetes)

Centralised repository for the monitoring assets that accompany the DevOps projects: Helm values for `kube-prometheus-stack`, custom Prometheus rules, ServiceMonitors, Loki settings, Grafana dashboards, and validation scripts.

## What this repo solves

- Keeps platform-wide monitoring configuration (Helm values + manifests) in version control.
- Documents the exact dashboards and alerts SREs rely on when operating the workloads from the companion projects.
- Provides scripts to smoke test health endpoints whenever the stack or dashboards change.

## Repository layout

| Path | Description |
| --- | --- |
| `prometheus-values.yaml` | Base configuration passed to `prometheus-community/kube-prometheus-stack` (retention, scrape intervals, component toggles). |
| `monitoring/` | Folder containing Prometheus rules, Grafana dashboards, Loki values, and supporting manifests. Each subdirectory has its own README with component-specific details. |
| `scripts/monitoring-smoketest.sh` | Validates that Grafana/Prometheus pods are healthy and that application ServiceMonitors are being scraped. |
| `scripts/metrics-canary.sh` & `scripts/trigger-alerts.sh` | Exercise app endpoints, push synthetic traffic, and confirm alerts fire as expected. |

## Installing the stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f prometheus-values.yaml --namespace monitoring --create-namespace
```

Apply custom components:

```bash
kubectl apply -f monitoring/prometheus/rules/alert-rules.yaml
kubectl apply -f monitoring/prometheus/servicemonitor.yaml
kubectl apply -f monitoring/loki/values.yaml   # if deploying Loki separately
```

## Smoke test workflow

```bash
./scripts/monitoring-smoketest.sh monitoring devops-app
```

The script checks:

1. Kubernetes namespace + pods (Prometheus, Grafana, Alertmanager) are running.
2. Prometheus `/-/ready` and Grafana `/api/health` endpoints return 200.
3. ServiceMonitor for `devops-app` is registered and scraping targets.

`metrics-canary.sh` and `trigger-alerts.sh` can then be used against the workload namespace to ensure instrumentation is live and alerts trigger under stress.

## Customising for environments

- Duplicate `prometheus-values.yaml` per environment (e.g., `prometheus-values-prod.yaml`). Adjust retention, storageClass, replica counts, and alertmanager receivers.
- Drop dashboards into `monitoring/grafana/dashboards/` and label them with `grafana_dashboard` so the sidecar loads them automatically.
- Keep PrometheusRule objects small (per domain/service) to simplify ownership and review.

## CI/CD expectations

- Run `helm lint` + `helm template` on every pull request touching Helm values.
- Execute `kubectl apply --dry-run=server -f monitoring/` to catch schema issues.
- Use `scripts/monitoring-smoketest.sh` to gate merges so broken dashboards/alerts never reach main.

## Cleanup

```bash
helm uninstall monitoring -n monitoring || true
kubectl delete namespace monitoring
```

Remember to delete persistent volumes if you created dedicated PVCs for Prometheus or Grafana.

This repo acts as the source of truth for the observability plane—treat it like application code and enjoy predictable monitoring rollouts across clusters.
