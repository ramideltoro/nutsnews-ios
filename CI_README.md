# NutsNews iOS CI

This update adds a GitHub Actions workflow that builds the native NutsNews iOS app on every push to `main`, pull request, or manual workflow run.

## Local build check

```bash
cd /Users/ramideltoro/WebstormProjects/nutsnews-ios
bash scripts/ci-build-ios.sh
```

The script builds the app for a generic iOS Simulator destination with signing disabled:

```bash
CODE_SIGNING_ALLOWED=NO
```

This verifies the app compiles without needing Apple Developer signing secrets.

## GitHub Actions

Workflow file:

```text
.github/workflows/ios-ci.yml
```

The workflow runs on:

- Pushes to `main` that touch iOS source files
- Pull requests that touch iOS source files
- Manual `workflow_dispatch`

TestFlight/App Store deployment is intentionally not included yet. That comes later after Apple Developer signing is set up.
