# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-14

### Added
- Initial release of Dockadvisor GitHub Action
- Docker-based action for analyzing Dockerfiles
- Support for configurable failure conditions:
  - `fail-on-error`: Fail the action if errors are found
  - `fail-on-warning`: Fail the action if warnings are found
  - `minimum-score`: Set minimum acceptable quality score (0-100)
- Outputs for score, errors, warnings, and result status
- GitHub annotations for each issue found in Dockerfiles
- Score-based quality assessment (0-100 scale)
- Support for analyzing custom Dockerfile paths
- Comprehensive documentation with usage examples
- Example workflow file for CI/CD integration
- 60+ validation rules including:
  - FROM instruction validation
  - RUN command checks
  - EXPOSE port validation
  - CMD/ENTRYPOINT format checks
  - ENV/ARG validation with secret detection
  - Global checks for casing, duplicate stages, undefined variables

[1.0.0]: https://github.com/zdk/dockadvisor-action/releases/tag/v1.0.0
