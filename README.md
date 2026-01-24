# Docker Images

A collection of hardened Docker images for various applications, automatically built and published to GitHub Container Registry.

## 📦 Available Images

| Application | Description | Workflow Status |
|-------------|-------------|-----------------|
| [Plex](https://www.plex.tv/) | Media server platform (with amdgpu transcoding support) | [![Plex](https://github.com/abihf/images/actions/workflows/plex.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/plex.yml) |
| [Sonarr](https://sonarr.tv/) | TV show automation | [![Sonarr](https://github.com/abihf/images/actions/workflows/sonarr.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/sonarr.yml) |
| [Radarr](https://radarr.video/) | Movie automation | [![Radarr](https://github.com/abihf/images/actions/workflows/radarr.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/radarr.yml) |
| [Prowlarr](https://prowlarr.com/) | Indexer manager for *arr apps | [![Prowlarr](https://github.com/abihf/images/actions/workflows/prowlarr.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/prowlarr.yml) |
| [SABnzbd](https://sabnzbd.org/) | Usenet binary newsreader | [![SABnzbd](https://github.com/abihf/images/actions/workflows/sabnzbd.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/sabnzbd.yml) |
| [qBittorrent](https://www.qbittorrent.org/) | BitTorrent client | [![qBittorrent](https://github.com/abihf/images/actions/workflows/qbittorrent.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/qbittorrent.yml) |
| [AdGuardHome](https://adguard.com/adguard-home/) | DNS sinkhole & ad blocker | [![AdGuardHome](https://github.com/abihf/images/actions/workflows/adguardhome.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/adguardhome.yml) |
| [Overseerr](https://overseerr.dev/) | Request management and media discovery tool | [![Overseerr](https://github.com/abihf/images/actions/workflows/overseerr.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/overseerr.yml) |
| [Restic](https://restic.net/) | Fast, secure backup program | [![Restic](https://github.com/abihf/images/actions/workflows/restic.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/restic.yml) |
| [Speedtest](https://github.com/librespeed/speedtest-rust) | Network speed testing (librespeed-rs) | [![Speedtest](https://github.com/abihf/images/actions/workflows/speedtest.yml/badge.svg)](https://github.com/abihf/images/actions/workflows/speedtest.yml) |

## 🚀 Usage

All images are published to GitHub Container Registry (GHCR). Pull them using:

```bash
docker pull ghcr.io/abihf/images/[application]:latest
```

### Examples

```bash
# Pull Plex
docker pull ghcr.io/abihf/images/plex:latest

# Pull Sonarr
docker pull ghcr.io/abihf/images/sonarr:latest

# Pull specific SHA version
docker pull ghcr.io/abihf/images/overseerr:abc123def456
```

## 🔨 Building Locally

Each application has its own Dockerfile in its respective directory:

```bash
# Build an image locally
cd <application>/
docker build -t my-custom-image .

# Example: Build Plex with Plex Pass
cd plex/
docker build -t my-plex .
```

## 🔄 CI/CD

All images are automatically built and published via GitHub Actions when:
- Changes are pushed to `main` branch affecting the application directory
- Changes are made to the workflow file
- Manually triggered via workflow dispatch

### Workflow Features

- **Build caching**: Utilizes GitHub Actions cache with workflow-scoped keys
- **Attestations**: Build provenance attestations for supply chain security
- **Optimized compression**: Uses estargz compression with force-compression
- **OCI compliance**: Images use OCI media types

### Image Tags

Each build produces two tags:
- `latest` - Latest successful build from main
- `<sha>` - Git commit SHA for version pinning

## 🏗️ Architecture

- **Base Images**: Uses hardened base images from `dhi.io`
- **Platform**: Built for `linux/amd64`
- **Compression**: estargz for faster cold starts
- **Security**: Attestation signatures for verifiable builds

## 📝 Adding a New Image

1. Create a new directory with the application name
2. Add a `Dockerfile`
3. Create a workflow file in `.github/workflows/`:
4. Update this README with the new application

## 🔐 Required Secrets

Configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `DOCKER_USER` | Username for Docker Hardened Images registry |
| `DOCKER_PASSWORD` | Password/token for Docker Hardened Images registry |

## 🔗 Links

- [GitHub Container Registry](https://github.com/abihf?tab=packages&repo_name=images)
- [Docker Hardened Images](https://dhi.io)
