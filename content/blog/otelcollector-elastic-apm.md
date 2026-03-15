---
title: "Using OtelCollector with Elastic APM"
date: 2026-03-15
author: "baldator"
tags: ["opentelemetry", "elastic", "apm", "observability", "monitoring", "devops"]
modules: ["OtelCollector"]
summary: "Send OpenTelemetry traces and metrics from your PowerShell scripts directly into Elastic APM using the OtelCollector module — no agent required."
---

[Elastic APM](https://www.elastic.co/observability/application-performance-monitoring) is a powerful application performance monitoring solution built into the Elastic Stack. What many teams don't realise is that since Elastic APM 7.12, it speaks **OTLP natively** — meaning you can send OpenTelemetry data straight into it without installing the Elastic APM agent. Combined with the **OtelCollector** PowerShell module, this gives you rich, searchable traces and metrics from your automation scripts, runbooks, and CI/CD pipelines, all surfaced inside Kibana.

## Why Elastic APM?

If your organisation already runs the Elastic Stack (Elasticsearch + Kibana), adding PowerShell observability costs almost nothing extra. Your traces land in the same place as your application traces, logs, and infrastructure metrics — ready to correlate in one pane of glass.

Key advantages:

- **No additional backend to operate** — reuse an existing Elastic cluster
- **Unified correlation** — link PowerShell traces to application logs via `trace.id`
- **Kibana APM UI** — service map, latency distributions, error tracking, out of the box
- **Standard OTLP protocol** — works with any OTLP-compatible tool, including OtelCollector

## Prerequisites

- PowerShell 7.0 or later
- OtelCollector module installed (`Install-Module -Name OtelCollector`)
- Elastic Stack 7.12+ (self-managed) **or** an [Elastic Cloud](https://cloud.elastic.co/) deployment

## Configuring Elastic APM to Accept OTLP

### Self-Managed Elastic Stack

Elastic APM Server accepts OTLP over gRPC on port **8200** (the same port as the APM protocol). No extra configuration is needed — OTLP ingestion is enabled by default.

If you have `apm-server.yml`, confirm (or add):

```yaml
apm-server:
  host: "0.0.0.0:8200"

# OTLP is enabled by default; nothing extra is required.
```

The OTLP gRPC endpoint is:

```
http://<apm-server-host>:8200
```

### Elastic Cloud

On Elastic Cloud the APM endpoint and secret token are shown in the **Integrations** → **APM** section of the Cloud console. Your OTLP endpoint is:

```
https://<deployment-id>.apm.<region>.cloud.es.io:443
```

Authentication uses the APM **secret token** passed as a header:

```
Authorization: Bearer <secret-token>
```

## Connecting OtelCollector to Elastic APM

### Install the Module

```powershell
Install-Module -Name OtelCollector -Scope CurrentUser
Import-Module OtelCollector
```

### Initialize the Tracer

Pass the Elastic APM OTLP endpoint and your secret token via the `-Headers` parameter:

```powershell
Import-Module OtelCollector

# --- Self-managed ---
Initialize-OtelTracer `
    -ServiceName    "PowerShell-Automation" `
    -Endpoint       "http://apm-server.internal:8200" `
    -ServiceVersion "1.0.0"

# --- Elastic Cloud (with authentication) ---
Initialize-OtelTracer `
    -ServiceName    "PowerShell-Automation" `
    -Endpoint       "https://<deployment-id>.apm.<region>.cloud.es.io:443" `
    -ServiceVersion "1.0.0" `
    -Headers        @{ Authorization = "Bearer $env:ELASTIC_APM_SECRET_TOKEN" }
```

> **Tip:** Store `ELASTIC_APM_SECRET_TOKEN` as a CI/CD secret or in a vault — never hard-code it in your scripts.

## Tracing a Deployment Pipeline

Here is a realistic example: tracing each phase of a production deployment so you can see exactly how long every step takes inside Kibana APM.

```powershell
Import-Module OtelCollector

Initialize-OtelTracer `
    -ServiceName    "Deployment-Pipeline" `
    -Endpoint       "https://<deployment-id>.apm.<region>.cloud.es.io:443" `
    -ServiceVersion "2.5.0" `
    -Headers        @{ Authorization = "Bearer $env:ELASTIC_APM_SECRET_TOKEN" }

$deploy = Start-OtelSpan -Name "deploy"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.environment" -Value "production"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.version"     -Value "2.5.0"
Set-OtelSpanAttribute -Span $deploy -Key "deploy.triggered_by" -Value $env:BUILD_USER

try {

    # Phase 1 — validate artifacts
    $validate = Start-OtelSpan -Name "validate-artifacts" -ParentSpan $deploy
    Test-DeploymentArtifacts -Path "./artifacts"
    Stop-OtelSpan -Span $validate

    # Phase 2 — database migration
    $migrate = Start-OtelSpan -Name "database-migration" -ParentSpan $deploy
    Set-OtelSpanAttribute -Span $migrate -Key "db.system" -Value "postgresql"
    Set-OtelSpanAttribute -Span $migrate -Key "db.name"   -Value "app_production"
    Invoke-DatabaseMigration -ConnectionString $env:DB_CONNECTION_STRING
    Stop-OtelSpan -Span $migrate

    # Phase 3 — deploy application
    $appDeploy = Start-OtelSpan -Name "deploy-application" -ParentSpan $deploy
    Set-OtelSpanAttribute -Span $appDeploy -Key "deployment.target" -Value "prod-web-01"
    Deploy-Application -Target "prod-web-01" -Version "2.5.0"
    Stop-OtelSpan -Span $appDeploy

    # Phase 4 — smoke tests
    $smoke = Start-OtelSpan -Name "smoke-tests" -ParentSpan $deploy
    Invoke-SmokeTests -BaseUrl "https://app.example.com"
    Stop-OtelSpan -Span $smoke

    Set-OtelSpanStatus -Span $deploy -Status "Ok"
    Write-Host "✅ Deployment succeeded"

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

After the script runs, open **Kibana → Observability → APM → Services** and you will see `Deployment-Pipeline` listed with its latency and error rate. Click into a trace to see the full waterfall — each phase as a separate span with its attributes.

## Sending Metrics to Elastic

OtelCollector can also send metrics that appear in Elastic's metrics explorer and can be alerted on:

```powershell
Import-Module OtelCollector

Initialize-OtelTracer `
    -ServiceName "Batch-Worker" `
    -Endpoint    "https://<deployment-id>.apm.<region>.cloud.es.io:443" `
    -Headers     @{ Authorization = "Bearer $env:ELASTIC_APM_SECRET_TOKEN" }

# Track how many jobs were processed in this run
Add-OtelMetric -Name "jobs.processed" -Value 250 -Type Counter `
               -Attributes @{ queue = "email-notifications"; status = "success" }

# Track current queue depth
Add-OtelMetric -Name "queue.depth" -Value (Get-QueueDepth -Queue "email-notifications") `
               -Type Gauge `
               -Attributes @{ queue = "email-notifications" }

# Track processing duration
Add-OtelMetric -Name "job.duration_ms" -Value 1342 -Type Gauge `
               -Attributes @{ queue = "email-notifications"; worker_id = $env:WORKER_ID }
```

Metrics show up under **Kibana → Observability → Metrics** and in the APM service overview.

## Practical Tips

### Use Environment Variables for the Endpoint

Avoid scattering the endpoint URL across many scripts. Use a single environment variable:

```powershell
Initialize-OtelTracer `
    -ServiceName "MyScript" `
    -Endpoint    $env:OTEL_EXPORTER_OTLP_ENDPOINT `
    -Headers     @{ Authorization = "Bearer $env:ELASTIC_APM_SECRET_TOKEN" }
```

Set `OTEL_EXPORTER_OTLP_ENDPOINT` in your CI/CD pipeline configuration or system environment and every script picks it up automatically.

### Add Resource Attributes for Better Filtering

Elastic APM uses the `service.name` and `service.version` attributes to group traces. Enrich them further with deployment-specific context:

```powershell
Initialize-OtelTracer `
    -ServiceName    "Batch-Worker" `
    -ServiceVersion $env:APP_VERSION `
    -Endpoint       $env:OTEL_EXPORTER_OTLP_ENDPOINT `
    -Headers        @{ Authorization = "Bearer $env:ELASTIC_APM_SECRET_TOKEN" }

$span = Start-OtelSpan -Name "process-batch"
Set-OtelSpanAttribute -Span $span -Key "host.name"         -Value $env:COMPUTERNAME
Set-OtelSpanAttribute -Span $span -Key "deployment.environment" -Value "production"
# ... work ...
Stop-OtelSpan -Span $span
```

### Correlating with Application Logs

If your application already sends logs to Elasticsearch, you can correlate them with your PowerShell traces by writing the trace ID into your log output:

```powershell
$span = Start-OtelSpan -Name "process-order"
$traceId = $span.Context.TraceId.ToString()

# Include trace.id in structured log output for correlation
Write-Host (ConvertTo-Json @{
    "@timestamp" = (Get-Date -Format "o")
    "message"    = "Processing order $orderId"
    "trace.id"   = $traceId
    "service"    = "Order-Processor"
})

# ... do work ...
Stop-OtelSpan -Span $span
```

In Kibana you can pivot from a trace directly to the correlated logs using the `trace.id` field.

## Viewing Results in Kibana

Once traces are flowing:

1. Open **Kibana → Observability → APM**
2. Your PowerShell service appears in the **Services** list
3. Click the service name to see **latency**, **throughput**, and **error rate** charts
4. Open **Transactions** to drill into individual trace waterfalls
5. Use **Service Map** to see how your automation relates to other instrumented services

For metrics, navigate to **Kibana → Observability → Metrics → Explorer** and search for the metric names you defined (e.g., `jobs.processed`).

## Conclusion

Elastic APM's native OTLP support and the OtelCollector PowerShell module are a natural fit. You get full distributed tracing and metrics for your PowerShell automation with no extra agents and no new backends to manage — just a handful of lines of PowerShell on top of your existing Elastic Stack.

```powershell
Install-Module -Name OtelCollector -Scope CurrentUser
```

Full module reference: [OtelCollector module page](/modules/otelcollector/) · [GitHub](https://github.com/baldator/PSOtelCollector)
