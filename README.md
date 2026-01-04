# Docker Images

A collection of hardened Docker images for various applications, automatically built and published to GitHub Container Registry.

## 📦 Available Images

| Application | Description | Workflow Status |
|-------------|-------------|-----------------|
| [Plex](plex/) | Media server platform | ![Plex](https://github.com/abihf/images/actions/workflows/plex.yml/badge.svg) |
| [Sonarr](sonarr/) | TV show automation | ![Sonarr](https://github.com/abihf/images/actions/workflows/sonarr.yml/badge.svg) |
| [SABnzbd](sabnzbd/) | Usenet binary newsreader | ![SABnzbd](https://github.com/abihf/images/actions/workflows/sabnzbd.yml/badge.svg) |
| [qBittorrent](qbittorrent/) | BitTorrent client | ![qBittorrent](https://github.com/abihf/images/actions/workflows/qbittorrent.yml/badge.svg) |
| [AdGuardHome](adguardhome/) | DNS sinkhole & ad blocker | ![AdGuardHome](https://github.com/abihf/images/actions/workflows/adguardhome.yml/badge.svg) |
| [Overseerr](overseerr/) | Request management and media discovery tool | ![Overseerr](https://github.com/abihf/images/actions/workflows/overseerr.yml/badge.svg) |
| [Restic](restic/) | Fast, secure backup program | ![Restic](https://github.com/abihf/images/actions/workflows/restic.yml/badge.svg) |
| [Speedtest](speedtest/) | Network speed testing (librespeed-rs) | ![Speedtest](https://github.com/abihf/images/actions/workflows/speedtest.yml/badge.svg) |

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

```yaml
name: Your App

on:
  push:
    branches:
      - main
    paths:
      - 'yourapp/**'
      - .github/workflows/yourapp.yml
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE: ${{ github.repository }}/yourapp

permissions:
  contents: read
  packages: write
  id-token: write
  attestations: write

jobs:
  build:
    name: Build and push
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Log in to Docker Hardened Images
        uses: docker/login-action@v3
        with:
          registry: dhi.io
          username: ${{ secrets.DOCKER_USER }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push image (latest, sha)
        id: build
        uses: docker/build-push-action@v6
        with:
          context: ./yourapp
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
          platforms: linux/amd64
          cache-from: type=gha,scope=${{ github.workflow }}
          cache-to: type=gha,mode=max,scope=${{ github.workflow }}
          outputs: type=registry,oci-mediatypes=true,compression=estargz,force-compression=true

      - name: Attest build provenance
        uses: actions/attest-build-provenance@v3
        with:
          subject-name: ${{ env.REGISTRY }}/${{ env.IMAGE }}
          subject-digest: ${{ steps.build.outputs.digest }}
          push-to-registry: true
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

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
