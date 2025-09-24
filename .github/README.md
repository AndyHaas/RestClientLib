# GitHub Actions Workflows

This repository includes automated workflows for package creation and release management.

## Available Workflows

### 1. Build & Bump (`build-and-bump.yml`)

**Purpose**: Main workflow that handles version bumping, package creation, and Salesforce deployment

**Trigger**: Manual (workflow_dispatch)

**Options**:
- **Release Type**: Choose from `patch`, `minor`, or `major`
- **Custom Version**: Override with a specific version number

**What it does**:
- Calculates new version based on current version and release type
- Updates `package.json`, `package.xml`, `sfdx-project.json`, and script versions
- Creates the package zip file
- Converts source to MDAPI format
- Deploys to Salesforce packaging org
- Commits version changes back to the repository
- Triggers the Publish Release workflow automatically

**How to use**:
1. Go to Actions tab in GitHub
2. Select "Build & Bump"
3. Click "Run workflow"
4. Choose release type or enter custom version
5. Click "Run workflow"

### 2. Publish Release (`publish-release.yml`)

**Purpose**: Creates GitHub releases and updates documentation after successful build

**Trigger**: Automatic (runs after Build & Bump completes successfully)

**What it does**:
- Downloads artifacts from the Build & Bump workflow
- Creates GitHub release with download links
- Updates README.md with latest release information
- Uploads package as release asset

**Note**: This workflow runs automatically after Build & Bump completes successfully.

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
