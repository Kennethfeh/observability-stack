#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${1:-monitoring}"
APP_NAMESPACE="${2:-devops-app}"

function require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] Required command '$1' not found in PATH" >&2
    exit 1
  fi
}

require_command kubectl

echo "=== Monitoring Stack Smoke Test ==="
echo "Context: $(kubectl config current-context 2>/dev/null || echo 'unknown')"
echo "Monitoring namespace: ${NAMESPACE}"

echo "-- Checking Prometheus pods --"
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=prometheus || true

echo "-- Checking Grafana pods --"
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=grafana || true

echo "-- Checking Alertmanager pods --"
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/name=alertmanager || true

echo "-- Validating ServiceMonitor for application --"
kubectl get servicemonitor devops-app-servicemonitor -n "${NAMESPACE}" || {
  echo "[WARN] ServiceMonitor devops-app-servicemonitor not found" >&2
}

echo "-- Validating target discovery --"
kubectl get endpoints -n "${APP_NAMESPACE}" devops-app-service || {
  echo "[WARN] Application service endpoints not ready" >&2
}

echo "-- Listing active alerts (if any) --"
kubectl get prometheusrule -n "${NAMESPACE}" || true
kubectl get alerts -n "${NAMESPACE}" 2>/dev/null || echo "No active alerts API available"

echo "Smoke test complete"
