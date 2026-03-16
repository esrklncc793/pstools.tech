---
title: "Introducing PSJinja: Jinja2 Templates for PowerShell"
date: 2026-03-16
author: "baldator"
tags: ["templates", "jinja2", "configuration", "automation", "powershell"]
modules: ["PSJinja"]
summary: "Move beyond simple string interpolation. PSJinja brings full Jinja2 templating to PowerShell — with variables, conditionals, loops, and filters for generating any kind of dynamic text output."
---

Generating dynamic text in PowerShell usually means choosing between messy string interpolation, here-strings with `$()` everywhere, or a logic-less template engine like Mustache. **PSJinja** offers a third path: [Jinja2](https://jinja.palletsprojects.com/) — one of the most expressive and widely-used templating languages in the world — brought directly to your PowerShell scripts.

## What Is Jinja2?

Jinja2 is a templating language originally built for Python, but its clean syntax and powerful features have made it the standard for configuration management tools like Ansible, Salt, and Cookiecutter. Unlike Mustache (which is intentionally logic-less), Jinja2 lets you express real logic inside templates:

- **Variables**: `{{ user.name }}`
- **Conditionals**: `{% if environment == "prod" %}...{% endif %}`
- **Loops**: `{% for item in items %}...{% endfor %}`
- **Filters**: `{{ name | upper }}`, `{{ list | join(', ') }}`
- **Comments**: `{# this is ignored in the output #}`

This makes Jinja2 the right choice whenever your output format requires logic — environment-specific configs, infrastructure manifests, HTML reports, and more.

## Why PSJinja?

PowerShell's native string interpolation works fine for simple cases:

```powershell
$message = "Hello, $name! You have $count messages."
```

But it falls apart quickly with real-world use cases:

- **Multi-line templates** become unreadable here-strings
- **Conditional blocks** require separate `if/else` logic outside the template
- **Loops** require `foreach` with string accumulation
- **Re-using template files** across scripts is awkward

PSJinja solves all of these by cleanly separating your template (the *shape* of the output) from your PowerShell data (the *values* that fill it in).

## Installation

```powershell
Install-Module -Name PSJinja -Scope CurrentUser
Import-Module PSJinja
```

## Your First PSJinja Template

```powershell
Import-Module PSJinja

$template = @"
Hello, {{ name }}!

{% if role == "admin" %}
You have full administrative access.
{% else %}
You have standard user access.
{% endif %}

Your assigned projects:
{% for project in projects %}
  - {{ project }}
{% endfor %}
"@

$data = @{
    name     = "Alice"
    role     = "admin"
    projects = @("Alpha", "Beta", "Gamma")
}

Invoke-PSJinjaTemplate -Template $template -Data $data
```

Output:
```
Hello, Alice!

You have full administrative access.

Your assigned projects:
  - Alpha
  - Beta
  - Gamma
```

## Real-World Use Case: Infrastructure Configuration

The killer use case for PSJinja is generating environment-specific configuration files in CI/CD pipelines. Instead of maintaining separate config files for dev, staging, and production, you maintain one template and inject the right values at deploy time.

**Template** (`appsettings.j2`):

```jinja
{
  "Database": {
    "ConnectionString": "Server={{ db_server }};Database={{ db_name }};Port={{ db_port }}"
  },
  "Logging": {
    "LogLevel": "{{ log_level }}"
  },
  "Cache": {
    "Enabled": {{ cache_enabled | lower }},
    "TTL": {{ cache_ttl }}
  },
  "Features": {
    {% for flag, value in features.items() %}
    "{{ flag }}": {{ value | lower }}{% if not loop.last %},{% endif %}
    {% endfor %}
  }
}
```

**PowerShell deployment script**:

```powershell
Import-Module PSJinja

$environments = @{
    dev = @{
        db_server     = "localhost"
        db_name       = "DevDB"
        db_port       = 5432
        log_level     = "Debug"
        cache_enabled = $false
        cache_ttl     = 60
        features      = @{ DarkMode = $true; BetaFeatures = $true }
    }
    production = @{
        db_server     = "prod-sql.company.internal"
        db_name       = "ProdDB"
        db_port       = 5432
        log_level     = "Warning"
        cache_enabled = $true
        cache_ttl     = 3600
        features      = @{ DarkMode = $true; BetaFeatures = $false }
    }
}

$env = $args[0]  # Pass "dev" or "production" as a script argument

Invoke-PSJinjaTemplate -TemplatePath "appsettings.j2" -Data $environments[$env] |
    Out-File "appsettings.$env.json" -Encoding utf8

Write-Host "✅ Generated appsettings.$env.json"
```

## Filters: The Secret Weapon

Jinja2 filters transform values inline, keeping your templates clean and readable. PSJinja supports all standard Jinja2 filters:

```powershell
$template = @"
Name:       {{ name | upper }}
Email:      {{ email | lower }}
Tags:       {{ tags | join(', ') }}
Count:      {{ items | length }}
Truncated:  {{ description | truncate(50) }}
Default:    {{ missing_value | default('N/A') }}
"@

$data = @{
    name        = "john doe"
    email       = "JOHN@EXAMPLE.COM"
    tags        = @("powershell", "automation", "devops")
    items       = @(1, 2, 3, 4, 5)
    description = "This is a very long description that should be truncated."
}

Invoke-PSJinjaTemplate -Template $template -Data $data
```

Output:
```
Name:       JOHN DOE
Email:      john@example.com
Tags:       powershell, automation, devops
Count:      5
Truncated:  This is a very long description that should b...
Default:    N/A
```

## Generating Kubernetes Manifests

PSJinja is particularly powerful for Kubernetes workflows where you need to generate YAML manifests for different environments:

```powershell
$deploymentTemplate = @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ app_name }}
  namespace: {{ namespace }}
spec:
  replicas: {{ replicas }}
  selector:
    matchLabels:
      app: {{ app_name }}
  template:
    metadata:
      labels:
        app: {{ app_name }}
        version: {{ version }}
    spec:
      containers:
      - name: {{ app_name }}
        image: {{ image }}:{{ version }}
        resources:
          requests:
            memory: "{{ memory_request }}"
            cpu: "{{ cpu_request }}"
          limits:
            memory: "{{ memory_limit }}"
            cpu: "{{ cpu_limit }}"
        env:
{% for key, value in env_vars.items() %}
        - name: {{ key }}
          value: "{{ value }}"
{% endfor %}
"@

$data = @{
    app_name       = "my-api"
    namespace      = "production"
    replicas       = 3
    version        = "v2.1.0"
    image          = "myregistry.azurecr.io/my-api"
    memory_request = "128Mi"
    memory_limit   = "256Mi"
    cpu_request    = "100m"
    cpu_limit      = "500m"
    env_vars       = @{
        DATABASE_URL = "postgresql://prod-db:5432/myapp"
        LOG_LEVEL    = "warning"
        CACHE_URL    = "redis://cache:6379"
    }
}

Invoke-PSJinjaTemplate -Template $deploymentTemplate -Data $data |
    Out-File "deployment.yaml" -Encoding utf8
```

## PSJinja vs Poshstache

Both PSJinja and [Poshstache](/modules/poshstache/) solve the same problem — generating dynamic text from templates — but they make different trade-offs:

| Feature | PSJinja | Poshstache |
|---------|---------|------------|
| Conditionals | ✅ Full `if/elif/else` | ✅ Via sections |
| Loops | ✅ `for` with loop variables | ✅ Via sections |
| Filters | ✅ Rich built-in filter library | ❌ |
| Logic in templates | ✅ Yes | ❌ By design |
| Template inheritance | ✅ `extends`/`block` | ❌ |
| Learning curve | Moderate | Low |
| Best for | Complex configs, infrastructure | Simple substitution |

Use **Poshstache** when your templates are straightforward variable substitutions. Use **PSJinja** when you need logic, filters, or reusable template components.

## Conclusion

PSJinja brings production-grade templating to PowerShell. Whether you're generating Kubernetes manifests, environment configs, HTML reports, or any other structured text output, PSJinja gives you the expressiveness of Jinja2 with the convenience of native PowerShell integration.

Get started in seconds:

```powershell
Install-Module -Name PSJinja -Scope CurrentUser
```

Check out the full documentation and source code on [GitHub](https://github.com/baldator/PSJinja), and explore the [module reference](/modules/psjinja/) for the complete API.
