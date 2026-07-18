# Software Patterns Homebrew Tap

Homebrew tap and binary distribution for Software Patterns CLI tools.

## Installation

### macOS (Homebrew)

```bash
brew tap softwarepatterns/tap
brew install jsonlog         # or: jsonmetrics, inbox-manager
```

### Linux (Debian/Ubuntu)

```bash
# Install jsonlog:
curl -sSL https://github.com/softwarepatterns/homebrew-tap/raw/main/install-deb.sh | bash -s jsonlog

# Install jsonmetrics:
curl -sSL https://github.com/softwarepatterns/homebrew-tap/raw/main/install-deb.sh | bash -s jsonmetrics

# Install inbox-manager:
curl -sSL https://github.com/softwarepatterns/homebrew-tap/raw/main/install-deb.sh | bash -s inbox-manager
```

## Available CLIs

| CLI | Description |
|-----|-------------|
| `jsonlog` | Structured JSON logging service CLI |
| `jsonmetrics` | Real-time in-memory metrics CLI |
| `inbox-manager` | Email automation and inbox management CLI |

## Supported Architectures

| Platform | Architectures |
|----------|--------------|
| macOS | Intel (x86_64), Apple Silicon (aarch64) |
| Linux | amd64, arm64 |
