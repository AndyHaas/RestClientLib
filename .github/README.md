# GitHub Actions Workflows

This repository includes automated workflows for package creation and release management.

## Available Workflows

### 1. Create Release Package (`release.yml`)

**Purpose**: Creates a full release with semantic versioning and GitHub release

**Trigger**: Manual (workflow_dispatch)

**Options**:
- **Release Type**: Choose from `patch`, `minor`, or `major`
- **Custom Version**: Override with a specific version number

**What it does**:
- Calculates new version based on current version and release type
- Updates `package.json`, `package.xml`, and script versions
- Creates the package zip file
- Creates a GitHub release with download link
- Commits version changes back to the repository
- Uploads package as release asset

**How to use**:
1. Go to Actions tab in GitHub
2. Select "Create Release Package"
3. Click "Run workflow"
4. Choose release type or enter custom version
5. Click "Run workflow"

### 2. Create Package (No Release) (`create-package.yml`)

**Purpose**: Creates a package zip file without creating a release

**Trigger**: Manual (workflow_dispatch)

**Options**:
- **Version**: Specify the package version

**What it does**:
- Creates package zip file with specified version
- Uploads as GitHub artifact (available for 7 days)
- No release or version commits

**How to use**:
1. Go to Actions tab in GitHub
2. Select "Create Package (No Release)"
3. Click "Run workflow"
4. Enter desired version
5. Click "Run workflow"

## Local Development

You can also create packages locally:

```bash
# Create package with current version
npm run create-package

# Or run the script directly
./scripts/create-package.sh

# Update version locally
npm run version:patch  # 1.0.0 -> 1.0.1
npm run version:minor  # 1.0.0 -> 1.1.0
npm run version:major  # 1.0.0 -> 2.0.0
```

## Version Management

The workflows use semantic versioning (SemVer):
- **Patch** (1.0.0 → 1.0.1): Bug fixes, small improvements
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Major** (1.0.0 → 2.0.0): Breaking changes, major updates

## Package Contents

Each generated package includes:
- All Apex classes
- Package.xml with correct API version
- Deploy script
- Package documentation
- Package metadata

## Artifacts

- **Release packages**: Available permanently as GitHub release assets
- **Non-release packages**: Available for 7 days as GitHub artifacts
