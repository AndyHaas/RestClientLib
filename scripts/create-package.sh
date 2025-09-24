#!/bin/bash

# REST API Library - Package Creation Script
# This script creates an unmanaged package for the RestClientLib

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="REST API Library"
PACKAGE_DESCRIPTION="A comprehensive Salesforce Apex library for making REST API callouts with ease, security, and reliability. This package provides a robust foundation for building REST integrations in Salesforce with built-in support for Named Credentials, async processing, and comprehensive testing utilities."
PACKAGE_VERSION="1"
API_VERSION="64.0"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 Creating unmanaged package: $PACKAGE_NAME${NC}"
echo -e "${BLUE}📁 Project root: $PROJECT_ROOT${NC}"

# Check if Salesforce CLI is installed
if ! command -v sf &> /dev/null; then
    echo -e "${RED}❌ Salesforce CLI (sf) is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}   Visit: https://developer.salesforce.com/tools/sfdxcli${NC}"
    exit 1
fi

# Check if we're authenticated
if ! sf org list --json | jq -e '.result[] | select(.isDefault == true)' > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  No default org found. Please authenticate first:${NC}"
    echo -e "${YELLOW}   sf org login web --set-default${NC}"
    exit 1
fi

# Get the default org info
DEFAULT_ORG=$(sf org list --json | jq -r '.result[] | select(.isDefault == true) | .alias')
echo -e "${GREEN}✅ Using org: $DEFAULT_ORG${NC}"

# Create a temporary directory for package contents
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}📦 Creating package in: $TEMP_DIR${NC}"

# Copy force-app contents to temp directory
cp -r "$PROJECT_ROOT/force-app" "$TEMP_DIR/"
cp "$PROJECT_ROOT/manifest/package.xml" "$TEMP_DIR/"

# Create package directory structure
PACKAGE_DIR="$TEMP_DIR/package"
mkdir -p "$PACKAGE_DIR"

# Copy the package.xml to the package directory
cp "$PROJECT_ROOT/manifest/package.xml" "$PACKAGE_DIR/"

# Create a deployment script
cat > "$PACKAGE_DIR/deploy.sh" << 'EOF'
#!/bin/bash
# Deploy script for REST API Library

echo "🚀 Deploying REST API Library to Salesforce org..."

# Deploy the package
sf project deploy start --source-dir force-app --wait 10

echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Create Named Credentials for your APIs"
echo "2. Extend RestClientLib class for your specific API needs"
echo "3. Write tests using the provided mock factory"
echo ""
echo "📖 See README.md for detailed usage instructions"
EOF

chmod +x "$PACKAGE_DIR/deploy.sh"

# Create a README for the package
cat > "$PACKAGE_DIR/README.md" << EOF
# $PACKAGE_NAME

$PACKAGE_DESCRIPTION

## Quick Start

1. **Deploy to your org:**
   \`\`\`bash
   ./deploy.sh
   \`\`\`

2. **Create a Named Credential:**
   - Go to Setup → Named Credentials
   - Create a new Named Credential for your API

3. **Extend RestClientLib:**
   \`\`\`apex
   public class MyApiClient extends RestClientLib {
       public MyApiClient() {
           super('My_Named_Credential');
       }
       
       public HttpResponse getUsers() {
           return get('/users');
       }
   }
   \`\`\`

## Package Contents

- **RestClientLib** - Main extensible class
- **RestClient** - Static wrapper for one-off calls
- **RestLib** - Core REST functionality
- **RestLibApiCall** - API call configuration
- **HttpVerb** - HTTP method enum
- **AsyncRestClient** - Async processing support
- **HttpCalloutMockFactory** - Testing utilities

## Documentation

See the main README.md for complete documentation and examples.

## Version

Version $PACKAGE_VERSION - API Version $API_VERSION
EOF

# Create a package info file
cat > "$PACKAGE_DIR/package-info.json" << EOF
{
  "name": "$PACKAGE_NAME",
  "description": "$PACKAGE_DESCRIPTION",
  "version": "$PACKAGE_VERSION",
  "apiVersion": "$API_VERSION",
  "type": "unmanaged",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "classes": [
    "AsyncRestClient",
    "AsyncRestLibFinalizer", 
    "HttpCalloutMockFactory",
    "HttpVerb",
    "RestClient",
    "RestClientLib",
    "RestLib",
    "RestLibApiCall",
    "RestLibTests"
  ]
}
EOF

# Create the final package archive
PACKAGE_FILE="$PROJECT_ROOT/REST-API-Library-v$PACKAGE_VERSION.zip"
cd "$TEMP_DIR"
zip -r "$PACKAGE_FILE" . -x "*.DS_Store" "*/.*"

# Clean up temp directory
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Package created successfully!${NC}"
echo -e "${GREEN}📦 Package file: $PACKAGE_FILE${NC}"
echo ""
echo -e "${BLUE}📋 Package Contents:${NC}"
echo -e "   • Apex Classes (9 classes)"
echo -e "   • Package.xml (API v$API_VERSION)"
echo -e "   • Deploy script"
echo -e "   • Package README"
echo -e "   • Package metadata"
echo ""
echo -e "${YELLOW}🚀 To deploy to an org:${NC}"
echo -e "   1. Extract the zip file"
echo -e "   2. Run: ./deploy.sh"
echo -e "   3. Or use: sf project deploy start --source-dir force-app"
echo ""
echo -e "${BLUE}📖 For detailed usage, see the README.md in the package${NC}"
