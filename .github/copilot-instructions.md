# Copilot Instructions: Docker Images Repository

## Project Overview
This repository manages hardened Docker images for 10+ applications (Plex, Sonarr, Radarr, Prowlarr, SABnzbd, qBittorrent, AdGuardHome, Overseerr, Restic, Speedtest) built and published to GitHub Container Registry (GHCR).

## Architecture Patterns

### Directory Structure
Each application follows an identical pattern:
```
<app>/
  ├── Dockerfile          # Multi-stage build with specific patterns
  └── update.sh          # Script to fetch latest version and update Dockerfile ARGs
```

### Key Architectural Principles
1. **Base images**: All images inherit from `dhi.io/{alpine-base,debian-base}:*` (hardened bases)
2. **Multi-stage builds**: Use `AS downloader` stage to fetch binaries, then copy to runtime stage
3. **Version parameterization**: Applications fetch latest versions via GitHub API in update scripts
4. **Non-root execution**: Images run as `nonroot:nonroot` user for security
5. **Platform targeting**: Built for `linux/amd64` platform only

## Version Update Workflow

### Update Scripts (`*/update.sh`)
Each app's `update.sh` sources `utils.sh` and updates the Dockerfile `ARG` dynamically:

**Pattern Types:**
- **GitHub Release Tags** (Sonarr, Radarr, etc.): 
  ```bash
  VERSION=$(get_latest_github_release_tag "Org/Repo" | sed 's/^v//')
  update_docker_arg "VERSION_ARG" "$VERSION"
  ```
- **GitHub Commits** (Speedtest): 
  ```bash
  COMMIT=$(get_latest_github_commit "Org/Repo" "branch-name")
  update_docker_arg "COMMIT_ARG" "$COMMIT"
  ```
- **Custom APIs** (Plex): 
  Fetch from vendor-specific endpoints with token authentication

### Shared Utilities (`utils.sh`)
Provides three core functions:
- `get_latest_github_release_tag()` - Extracts latest release from GitHub API
- `get_latest_github_commit()` - Gets latest commit SHA on a branch
- `update_docker_arg()` - Uses `sed` to update `ARG KEY=value` in Dockerfile

### Running Updates
- Individual app: `bash plex/update.sh`
- All apps: `bash update-all.sh` (runs all `*/update.sh` in sequence, fails if any script fails)

## Dockerfile Conventions

### ARG Placement
Version arguments appear just befere usage in the Dockerfile:
```dockerfile
ARG VERSION=1.2.3
ADD --link https://.../${VERSION}/file.tar.gz archive.tar.gz
```

### Common Patterns
- **Downloader stage**: Downloads binaries with `ADD --link` (creates cache layer)
- **Caching mounts**: Uses `--mount=type=cache` for `/var/cache/apt` and `/var/lib/apt`
- **Multi-platform variations**: Some apps (Sonarr) have Alpine vs Debian variants
- **Configuration paths**: Apps expect config at `/config` volume
- **Environment variables**: Set app-specific paths (see Plex `LD_LIBRARY_PATH`, Sonarr `COMPlus_EnableDiagnostics`)

## CI/CD Integration

### GitHub Actions Workflows
Workflows auto-build when:
- Changes pushed to `main` affecting the app directory
- Workflow file itself changes
- Manual trigger via workflow dispatch

### Build Output
Each push generates:
- `latest` tag for current build
- `<git-sha>` tag for version pinning
- Build attestations (OCI compliance + supply chain security)

## Development Guidelines

### Adding a New Application
1. Create new directory: `myapp/`
2. Write `Dockerfile` following multi-stage pattern with `ARG` for version
3. Write `update.sh` to fetch latest version and call `update_docker_arg`
4. Create `.github/workflows/myapp.yml` triggering on `myapp/**` path changes
5. Add entry to README.md table

### Testing Updates Locally
```bash
# Build an image
cd <app>/
docker build -t test:<app> .

# Run update script to refresh ARGs
bash update.sh

# Rebuild with new versions
docker build -t test:<app> .
```

### Environment Configuration
Optional `.env` file at repo root can override:
- GitHub tokens (for API rate limiting)
- Custom endpoints
- Build flags

Sourced in `utils.sh`: `source .env` if file exists

## Key Files
- [utils.sh](../utils.sh) - Shared GitHub API helpers and Dockerfile ARG updater
- [update-all.sh](../update-all.sh) - Master orchestration script
- [plex/update.sh](../plex/update.sh) - Custom API integration example (token auth)
- [sonarr/Dockerfile](../sonarr/Dockerfile) - Multi-stage example with package_info metadata
- [README.md](../README.md) - Workflow badges and GHCR registry info

## Common Pitfalls
- **GitHub API rate limits**: Add `.env` with `GITHUB_TOKEN` for 5000 req/hour vs 60
- **ARG case sensitivity**: `update_docker_arg` uses case-sensitive sed regex
- **Base image availability**: Verify `dhi.io` images exist for chosen Alpine/Debian tags
- **Volume mounts**: Config always at `/config` for consistency across apps
