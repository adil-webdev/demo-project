# Demo Project

A Ruby on Rails application with a fully automated CI pipeline powered by GitHub Actions and static code analysis using SonarQube.

## Tech Stack

- **Ruby** 4.0.0
- **Rails** 8.1
- **Database** MySQL (via `mysql2`)
- **Web server** Puma
- **Frontend** Propshaft, Importmap, Hotwire (Turbo + Stimulus)

## Getting Started

### Prerequisites

- Ruby 4.0.0 (see `.ruby-version`)
- MySQL 5.6.4+
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Create and migrate the database
bin/rails db:create db:migrate

# Start the server
bin/rails server
```

The app will be available at `http://localhost:3000`.

### Running Tests

```bash
bin/rails db:test:prepare test
```

Test coverage is collected with SimpleCov and written to `coverage/.resultset.json`.

## CI Pipeline (GitHub Actions)

Every push to `main` triggers the CI workflow defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml). The pipeline runs three sequential jobs:

### 1. `scan_ruby`

- Checks out the code and sets up Ruby with bundler caching.
- Placeholder steps are included for Brakeman (Rails security scan) and bundler-audit (gem vulnerability scan), currently commented out — these checks run in the SonarQube stage instead.

### 2. `test`

- Spins up a **MySQL service container** (database `sqe_test`, exposed on port 3307) with health checks.
- Installs `default-libmysqlclient-dev`, sets up Ruby, and runs the full test suite via `bin/rails db:test:prepare test`.
- Renames `coverage/.resultset.json` to `coverage/coverage.json` for SonarQube compatibility.
- Uploads the coverage report as a workflow artifact (`coverage-report`) for the SonarQube job.

### 3. `sonarqube`

- Downloads the coverage artifact from the `test` job.
- Generates a **Brakeman** security report in SonarQube format (`brakeman-sonar.json`).
- Generates a **RuboCop** lint report in JSON format (`rubocop-sonar.json`).
- Runs the **SonarQube scan** (`SonarSource/sonarqube-scan-action`), which uploads code quality, coverage, security, and lint results to the SonarQube server.
- Enforces the **Quality Gate** (`SonarSource/sonarqube-quality-gate-action`) — the pipeline fails if the project does not meet the configured quality thresholds.

```
push to main
     │
     ▼
 scan_ruby ──► test ──► sonarqube
              (MySQL,   (Brakeman + RuboCop +
               tests,    SonarQube scan +
               coverage)  Quality Gate)
```

## Static Analysis with SonarQube

The pipeline integrates the following analyzers, all reported through SonarQube:

| Tool       | Purpose                                              | Report file            |
| ---------- | ---------------------------------------------------- | ---------------------- |
| SonarQube  | Code quality, bugs, code smells, coverage, duplication | (server-side)          |
| Brakeman   | Rails security vulnerabilities                       | `brakeman-sonar.json`  |
| RuboCop    | Ruby style and lint offenses                         | `rubocop-sonar.json`   |
| SimpleCov  | Test coverage imported into SonarQube                | `coverage/coverage.json` |

### SonarQube Project Configuration

Analysis behavior is defined in `sonar-project.properties`:

- **Project key**: `adil-webdev_demo-project`
- **Sources analyzed**: `app/`, `lib/` (tests in `test/`)
- **Exclusions**: `node_modules/`, `vendor/`, `tmp/`, `log/`, `public/`, and `db/schema.rb`
- **Coverage import**: `sonar.ruby.coverage.reportPaths=coverage/coverage.json`
- **RuboCop import**: `sonar.ruby.rubocop.reportPaths=rubocop.json`
- **Brakeman import**: `sonar.externalIssuesReportPaths=brakeman-sonar.json`

### Required GitHub Secrets

Configure these in **Settings → Secrets and variables → Actions**:

- `SONAR_TOKEN` — authentication token for your SonarQube server
- `SONAR_HOST_URL` — URL of your SonarQube instance (e.g. `https://sonar.example.com`)

## Deployment

The app is containerized (see `Dockerfile`) and configured for deployment with [Kamal](https://kamal-deploy.org) (see `.kamal/`).

## License

This project is for demonstration purposes.
