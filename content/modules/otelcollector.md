---
title: "OtelCollector"
date: 2024-01-02
summary: "A PowerShell module for sending OpenTelemetry traces and metrics — bring observability to your PowerShell scripts and automation pipelines."
icon: "📡"
version: "1.0.0"
author: "baldator"
license: "MIT"
powershell_version: "7.0"
last_updated: "2026-02-19"
github_url: "https://github.com/baldator/PSOtelCollector"
github_stars: 1
gallery_url: "https://www.powershellgallery.com/packages/OtelCollector/"
issues_url: "https://github.com/baldator/PSOtelCollector/issues"
changelog_url: "https://github.com/baldator/PSOtelCollector/blob/main/CHANGELOG.md"
install_cmd: "Install-Module -Name OtelCollector"
downloads: "467"
color: "#1a1a2e"
tags: ["opentelemetry", "observability", "tracing", "metrics", "monitoring"]
weight: 2
---

## Overview

**OtelCollector** (PSOtelCollector) is a PowerShell module that enables sending [OpenTelemetry](https://opentelemetry.io/) telemetry data — traces, spans, and metrics — directly from PowerShell scripts to any OpenTelemetry-compatible backend (Jaeger, Zipkin, Grafana Tempo, Azure Monitor, etc.).

Bring modern observability practices to your PowerShell automation, runbooks, and CI/CD pipelines.

---

## Installation

Install from the [PowerShell Gallery](https://www.powershellgallery.com/packages/OtelCollector/):

```powershell
# Install for current user
Install-Module -Name OtelCollector -Scope CurrentUser

# Import
Import-Module OtelCollector
```

> **Note:** Requires PowerShell 7.0 or later.

---

## Quick Start

### Initialize the Tracer

```powershell
Import-Module OtelCollector

# Configure the OTLP exporter endpoint
Initialize-OtelTracer -ServiceName "MyAutomation" -Endpoint "http://localhost:4317"
```

### Create a Trace and Spans

```powershell
# Start a root span
$span = Start-OtelSpan -Name "deploy-application"

try {
    # Add attributes to the span
    Set-OtelSpanAttribute -Span $span -Key "deployment.environment" -Value "production"
    Set-OtelSpanAttribute -Span $span -Key "app.version" -Value "2.5.0"

    # Child span for a sub-operation
    $childSpan = Start-OtelSpan -Name "run-migration" -ParentSpan $span
    try {
        # ... perform database migration ...
        Invoke-SqlMigration -Server "prod-db" -Database "AppDB"
    } finally {
        Stop-OtelSpan -Span $childSpan
    }

    Write-Host "Deployment complete"
} catch {
    Set-OtelSpanStatus -Span $span -Status "Error" -Description $_.Exception.Message
    throw
} finally {
    Stop-OtelSpan -Span $span
}
```

---

## Commands

### Initialization

| Command | Description |
|---------|-------------|
| `Initialize-OtelTracer` | Configure and initialize the OpenTelemetry tracer |

### Tracing

| Command | Description |
|---------|-------------|
| `Start-OtelSpan` | Begin a new span |
| `Stop-OtelSpan` | End a span and export it |
| `Set-OtelSpanAttribute` | Add a key-value attribute to a span |
| `Set-OtelSpanStatus` | Set the status of a span (Ok / Error) |
| `Add-OtelSpanEvent` | Add a timed event to a span |

---

## Configuration

### `Initialize-OtelTracer` Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ServiceName` | `string` | `"PowerShell"` | Name of the service reported in traces |
| `-Endpoint` | `string` | `"http://localhost:4317"` | OTLP gRPC endpoint URL |
| `-ServiceVersion` | `string` | `"1.0.0"` | Service version attribute |
| `-Headers` | `hashtable` | `@{}` | Additional headers (e.g., auth tokens) |

---

## Examples

### Trace a CI/CD Pipeline

```powershell
Import-Module OtelCollector

Initialize-OtelTracer -ServiceName "CI-Pipeline" -Endpoint "http://otel-collector:4317"

$pipeline = Start-OtelSpan -Name "ci-pipeline"
Set-OtelSpanAttribute -Span $pipeline -Key "git.branch" -Value "main"
Set-OtelSpanAttribute -Span $pipeline -Key "git.commit" -Value $env:GIT_SHA

# Run tests
$testSpan = Start-OtelSpan -Name "run-tests" -ParentSpan $pipeline
# ... run tests ...
Stop-OtelSpan -Span $testSpan

# Build artifact
$buildSpan = Start-OtelSpan -Name "build" -ParentSpan $pipeline
# ... build ...
Stop-OtelSpan -Span $buildSpan

Stop-OtelSpan -Span $pipeline
```

### Send Metrics

```powershell
# Record a counter metric
Add-OtelMetric -Name "jobs.processed" -Value 1 -Type Counter `
               -Attributes @{ queue = "email"; status = "success" }

# Record a gauge
Add-OtelMetric -Name "queue.depth" -Value 42 -Type Gauge `
               -Attributes @{ queue = "email" }
```

---

## Backend Integrations

OtelCollector is compatible with any OTLP-supporting backend:

- **[Jaeger](https://www.jaegertracing.io/)** — Open-source distributed tracing
- **[Grafana Tempo](https://grafana.com/oss/tempo/)** — Scalable distributed tracing
- **[Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/)** — Full-stack monitoring
- **[Datadog](https://www.datadoghq.com/)** — via OTLP ingest
- **[Honeycomb](https://www.honeycomb.io/)** — Observability for modern teams

---

## Contributing

See the [GitHub repository](https://github.com/baldator/PSOtelCollector) for contribution guidelines.

---

## License

OtelCollector is released under the [MIT License](https://github.com/baldator/PSOtelCollector/blob/main/LICENSE).
