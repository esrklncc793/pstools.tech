---
title: "OpenTelemetry in PowerShell: Observability for Your Scripts"
date: 2024-02-20
author: "baldator"
tags: ["opentelemetry", "observability", "monitoring", "devops"]
modules: ["OtelCollector"]
summary: "Bring modern observability to your PowerShell scripts and automation pipelines using the OtelCollector module — traces, spans, and metrics from PowerShell."
---

Modern applications are instrumented with distributed tracing — so why should your PowerShell automation be any different? With **OtelCollector**, you can send OpenTelemetry traces and metrics from your PowerShell scripts to any compatible observability backend.

## The Observability Gap in Automation

When a deployment script fails at 2 AM, what do you have to debug with? Usually just raw log lines. You can't easily tell:

- How long each step took
- Which call in a chain of API requests was the slow one  
- Whether a transient error or a genuine failure caused the problem

OpenTelemetry solves this with **distributed traces** — a structured, hierarchical view of what happened and when.

## Introducing OtelCollector

**OtelCollector** (the `OtelCollector` PowerShell module) wraps the OpenTelemetry .NET SDK, making it straightforward to create traces and spans from PowerShell scripts.

### Install

```powershell
Install-Module -Name OtelCollector -Scope CurrentUser
Import-Module OtelCollector
```

> Requires PowerShell 7.0+

## Core Concepts

- **Trace**: A complete end-to-end operation (e.g., a full deployment run)
- **Span**: A named, timed operation within a trace (e.g., "download packages", "run migrations")
- **Attributes**: Key-value metadata attached to spans
- **Events**: Time-stamped log points within a span

## Instrumenting a Deployment Script

Here's a real-world example: tracing a deployment pipeline.

```powershell
Import-Module OtelCollector

# Initialize — point to your OTLP endpoint
Initialize-OtelTracer -ServiceName "Deployment" `
                      -Endpoint "http://otel-collector.internal:4317" `
                      -ServiceVersion "1.0.0"

# Root span for the entire deployment
$deploy = Start-OtelSpan -Name "deploy"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.target"      -Value "production"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.version"     -Value "v2.5.0"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.triggered_by" -Value $env:BUILD_USER

try {
    # --- Step 1: Validate ---
    $validate = Start-OtelSpan -Name "validate-artifacts" -ParentSpan $deploy
    Test-DeploymentArtifacts -Path "./artifacts"
    Stop-OtelSpan -Span $validate

    # --- Step 2: Database Migration ---
    $migrate = Start-OtelSpan -Name "database-migration" -ParentSpan $deploy
    Set-OtelSpanAttribute -Span $migrate -Key "db.server" -Value "prod-db"
    Invoke-DatabaseMigration -Server "prod-db"
    Stop-OtelSpan -Span $migrate

    # --- Step 3: Deploy App ---
    $appDeploy = Start-OtelSpan -Name "deploy-application" -ParentSpan $deploy
    Deploy-Application -Target "prod-web" -Version "v2.5.0"
    Stop-OtelSpan -Span $appDeploy

    Set-OtelSpanStatus -Span $deploy -Status "Ok"
    Write-Host "✅ Deployment complete"

} catch {
    Set-OtelSpanStatus -Span $deploy -Status "Error" -Description $_.Exception.Message
    Add-OtelSpanEvent -Span $deploy -Name "deployment.failed" `
                     -Attributes @{ "error.message" = $_.Exception.Message }
    Write-Error "❌ Deployment failed: $_"
    throw
} finally {
    Stop-OtelSpan -Span $deploy
}
```

## Visualizing in Jaeger

Once you're sending traces, fire up [Jaeger](https://www.jaegertracing.io/) locally:

```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  jaegertracing/all-in-one:latest
```

Then open `http://localhost:16686` to see your PowerShell traces with full flame graphs and timing data.

## Sending Metrics

Beyond traces, OtelCollector can send metrics:

```powershell
# Track job throughput
Add-OtelMetric -Name "jobs.completed" -Value 1 -Type Counter `
               -Attributes @{ job_type = "email"; status = "success" }

# Track queue depth
Add-OtelMetric -Name "queue.size" -Value (Get-QueueDepth) -Type Gauge `
               -Attributes @{ queue = "notifications" }
```

## Supported Backends

OtelCollector sends data via the standard OTLP protocol, which is supported by:

| Backend | Notes |
|---------|-------|
| [Jaeger](https://www.jaegertracing.io/) | Great for local development |
| [Grafana Tempo](https://grafana.com/oss/tempo/) | Pairs well with Grafana dashboards |
| [Azure Monitor](https://azure.microsoft.com/en-us/products/monitor/) | Native Azure integration |
| [Datadog](https://www.datadoghq.com/) | Via OTLP ingestion endpoint |
| [Honeycomb](https://www.honeycomb.io/) | Excellent query UX |

## Conclusion

You shouldn't have to choose between "write a script" and "have observability." With OtelCollector, you can have both. Start small — add a root span to your next deployment script — and build from there.

```powershell
Install-Module -Name OtelCollector -Scope CurrentUser
```

Source code and full documentation: [GitHub](https://github.com/baldator/PSOtelCollector).
