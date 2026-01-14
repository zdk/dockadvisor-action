# Dockadvisor GitHub Action

A GitHub Action that analyzes and lints Dockerfiles for best practices, security issues, and potential problems using [Dockadvisor](https://github.com/deckrun/dockadvisor).

## Features

- Analyzes Dockerfiles for 60+ validation rules
- Checks best practices, security, and syntax issues
- Provides a quality score (0-100)
- Creates GitHub annotations for each issue found
- Configurable failure conditions
- Fast and lightweight

## Usage

### Basic Example

```yaml
name: Dockerfile Lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint Dockerfile
        uses: zdk/dockadvisor-action@v1
        with:
          dockerfile: 'Dockerfile'
```

### Advanced Example

```yaml
name: Dockerfile Lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint Dockerfile
        id: dockadvisor
        uses: zdk/dockadvisor-action@v1
        with:
          dockerfile: 'Dockerfile'
          fail-on-error: 'true'
          fail-on-warning: 'false'
          minimum-score: '80'

      - name: Check results
        run: |
          echo "Score: ${{ steps.dockadvisor.outputs.score }}"
          echo "Errors: ${{ steps.dockadvisor.outputs.errors }}"
          echo "Warnings: ${{ steps.dockadvisor.outputs.warnings }}"
          echo "Result: ${{ steps.dockadvisor.outputs.result }}"
```

### Multiple Dockerfiles

```yaml
name: Lint All Dockerfiles
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        dockerfile:
          - 'Dockerfile'
          - 'Dockerfile.dev'
          - 'docker/Dockerfile.test'
    steps:
      - uses: actions/checkout@v4

      - name: Lint ${{ matrix.dockerfile }}
        uses: zdk/dockadvisor-action@v1
        with:
          dockerfile: ${{ matrix.dockerfile }}
          fail-on-error: 'true'
          minimum-score: '75'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `dockerfile` | Path to the Dockerfile to analyze | No | `Dockerfile` |
| `fail-on-error` | Fail the action if errors are found | No | `false` |
| `fail-on-warning` | Fail the action if warnings are found | No | `false` |
| `minimum-score` | Minimum acceptable score (0-100). Fail if score is below this threshold | No | `0` |

## Outputs

| Output | Description |
|--------|-------------|
| `score` | The Dockerfile quality score (0-100) |
| `errors` | Number of errors found |
| `warnings` | Number of warnings found |
| `result` | Overall result: `passed` or `failed` |

## Validation Rules

Dockadvisor checks for 60+ validation rules including:

- **FROM instruction**: Image reference validation, platform flags, stage names
- **RUN instruction**: Command validation, mount flags, network flags
- **WORKDIR**: Path validation
- **EXPOSE**: Port format, range, and protocol validation
- **CMD/ENTRYPOINT**: JSON array format validation
- **ENV/ARG**: Key-value format, secret detection
- **USER**: Format validation
- **LABEL**: Key-value pair validation
- **COPY/ADD**: Arguments validation
- **Global checks**: Casing consistency, duplicate stages, undefined variables, secrets

## Scoring System

The score is calculated as:

```
Score = 100 - (errors × 15 + warnings × 5)
```

- Fatal rules result in a score of 0
- Errors: -15 points each
- Warnings: -5 points each
- Minimum score: 0

## Examples of Issues Detected

- Invalid image references in FROM
- Missing required arguments
- Exposed port format issues
- Undefined variables
- Duplicate stage names
- Secrets in environment variables
- Invalid JSON syntax in CMD/ENTRYPOINT
- And many more...

## GitHub Annotations

The action automatically creates GitHub annotations for each issue found, making it easy to see problems directly in your pull request or commit view.

## License

This action uses [Dockadvisor](https://github.com/deckrun/dockadvisor), which is licensed under the Apache License 2.0.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/zdk/dockadvisor-action/issues).

## Related Projects

- [Dockadvisor](https://github.com/deckrun/dockadvisor) - The underlying Dockerfile linter
- [Hadolint](https://github.com/hadolint/hadolint) - Another popular Dockerfile linter
