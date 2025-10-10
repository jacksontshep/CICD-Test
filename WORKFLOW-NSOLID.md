# GitHub Actions with NSolid Runtime

## Overview

The CI/CD workflow has been configured to run with **NSolid runtime** instead of standard Node.js, enabling advanced profiling and monitoring during automated tests.

## Key Changes

### Container Configuration

The workflow now runs inside the `nodesource/nsolid:latest` Docker container:

```yaml
container:
  image: nodesource/nsolid:latest
  env:
    NSOLID_SAAS: ${{ secrets.NSOLID_SAAS }}
    NSOLID_APPNAME: cicd-test
    NSOLID_TAGS: ci,github-actions,load-test
    NSOLID_TRACING_ENABLED: 1
```

### Matrix Strategy

Tests run in parallel using a matrix strategy:
- **k6 load test** - High-performance load testing
- **Artillery load test** - Scenario-based load testing

Both test suites run with NSolid profiling enabled.

## Setup Instructions

### 1. Add GitHub Secret

1. Navigate to your repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `NSOLID_SAAS`
5. Value: Your NSolid SaaS token from [console.nodesource.com](https://console.nodesource.com)

### 2. Verify Workflow

Push to `main` or `develop` branch, or create a PR to trigger the workflow.

### 3. View Results

- **GitHub Actions**: Check workflow runs for test results
- **NSolid Console**: View profiling data at [console.nodesource.com](https://console.nodesource.com)
- **Artifacts**: Download test results from workflow runs

## What Gets Profiled

During CI/CD runs, NSolid captures:

- **CPU profiles** - Identify performance bottlenecks
- **Memory usage** - Track heap and RSS during load tests
- **Request metrics** - Monitor throughput and latency
- **Error tracking** - Catch runtime issues
- **Distributed tracing** - Follow request flows (when enabled)

## Workflow Triggers

The workflow runs on:

1. **Push** to `main` or `develop` branches
2. **Pull requests** to `main` branch
3. **Manual dispatch** with custom parameters:
   - `duration` - Test duration in seconds (default: 60)
   - `target` - Target requests per second (default: 50)

## Benefits vs Standard Node.js

| Feature | Standard Node.js | NSolid |
|---------|-----------------|--------|
| Runtime profiling | ❌ | ✅ |
| Memory leak detection | Limited | Advanced |
| CPU flame graphs | Manual | Automatic |
| Distributed tracing | Requires setup | Built-in |
| Security monitoring | ❌ | ✅ |
| Performance metrics | Basic | Comprehensive |

## Troubleshooting

### Missing NSOLID_SAAS Secret

**Error:** Workflow runs but no data appears in NSolid Console

**Solution:** Add the `NSOLID_SAAS` secret to repository settings

### Container Permissions

**Error:** `apt-get` commands fail with permission errors

**Solution:** Commands in the workflow already use appropriate permissions (no `sudo` needed in containers)

### Profiling Data Not Appearing

**Checklist:**
- ✅ `NSOLID_SAAS` secret is set correctly
- ✅ Token is valid and not expired
- ✅ Application name matches in NSolid Console
- ✅ Network allows outbound connections to NSolid SaaS

## Comparing with Local Development

| Environment | Runtime | Configuration |
|-------------|---------|---------------|
| **Local (npm start)** | Node.js or NSolid | Manual setup |
| **Docker Compose** | NSolid v6 | `docker-compose.yml` |
| **GitHub Actions** | NSolid (container) | `.github/workflows/load-test.yml` |

All three environments can now use NSolid for consistent profiling across development, testing, and CI/CD.

## Next Steps

1. **Add secret** to GitHub repository
2. **Push changes** to trigger workflow
3. **Monitor** NSolid Console during test runs
4. **Analyze** performance data and optimize bottlenecks
5. **Compare** metrics across different commits

## Additional Resources

- [NSolid Documentation](https://docs.nodesource.com/)
- [NSolid Console](https://console.nodesource.com)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
