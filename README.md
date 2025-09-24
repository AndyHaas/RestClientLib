# RestClientLib

A comprehensive Salesforce Apex library for making REST API callouts with ease, security, and reliability. This package provides a robust foundation for building REST integrations in Salesforce with built-in support for Named Credentials, async processing, and comprehensive testing utilities.

## Latest Release
<!--LATEST-RELEASE-START-->
_No release yet_
<!--LATEST-RELEASE-END-->

## Features

- **🔐 Named Credential Integration**: Secure API callouts using Salesforce Named Credentials
- **🚀 Convenient HTTP Methods**: Simple `get()`, `post()`, `put()`, `patch()`, and `del()` methods
- **⚡ Async Processing**: Queueable-based async REST callouts with finalizer pattern
- **🧪 Comprehensive Testing**: Built-in mock factory and test utilities
- **🛡️ Type Safety**: Strongly typed HTTP verbs and API call objects
- **⚠️ Error Handling**: Robust error handling and timeout management
- **🔧 Extensible Design**: Virtual classes designed for easy extension

## Quick Start

### Basic Usage - Extending RestClientLib

The recommended approach is to extend `RestClientLib` for your specific API:

```apex
public class MyApiClient extends RestClientLib {
    public MyApiClient() {
        super('My_Named_Credential');
    }
    
    public HttpResponse getUsers() {
        return get('/users');
    }
    
    public HttpResponse getUserById(Id userId) {
        return get('/users/' + userId);
    }
    
    public HttpResponse createUser(String userData) {
        return post('/users', userData);
    }
    
    public HttpResponse updateUser(Id userId, String userData) {
        return put('/users/' + userId, userData);
    }
    
    public HttpResponse deleteUser(Id userId) {
        return del('/users/' + userId);
    }
}

// Usage
MyApiClient client = new MyApiClient();
HttpResponse response = client.getUsers();
if (response.getStatusCode() == 200) {
    // Process response
    String responseBody = response.getBody();
}
```

### Static Usage - One-off Calls

For one-off API calls, use the static `RestClient` class:

```apex
// Simple GET request
RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.GET, 
    '/api/users', 
    '?active=true', 
    ''
);
HttpResponse response = RestClient.makeApiCall('My_Named_Credential', apiCall);

// POST request with body
Map<String, Object> userData = new Map<String, Object>{
    'name' => 'John Doe',
    'email' => 'john@example.com'
};

RestLibApiCall postCall = new RestLibApiCall(
    HttpVerb.POST, 
    '/api/users', 
    '', 
    JSON.serialize(userData)
);
HttpResponse postResponse = RestClient.makeApiCall('My_Named_Credential', postCall);
```

### Async Usage - Background Processing

For non-critical or bulk operations, use async processing:

```apex
// Create your finalizer class
public class MyWebhookFinalizer extends AsyncRestLibFinalizer {
    public override void execute() {
        if (response.getStatusCode() == 200) {
            // Process successful response
            System.debug('Webhook sent successfully');
        } else {
            // Handle error
            System.debug('Webhook failed: ' + response.getBody());
        }
    }
}

// Queue the async call
Map<String, Object> webhookData = new Map<String, Object>{
    'event' => 'user.created',
    'data' => userData
};

RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.POST, 
    '/api/webhooks', 
    '', 
    JSON.serialize(webhookData)
);

System.enqueueJob(new AsyncRestClient(
    'My_Named_Credential', 
    apiCall, 
    MyWebhookFinalizer.class
));
```

## API Reference

### RestClientLib Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `get(String path)` | GET request to specified path | `path` - API endpoint path |
| `get(String path, String query)` | GET request with query parameters | `path` - API endpoint path, `query` - Query string |
| `post(String path, String body)` | POST request with body | `path` - API endpoint path, `body` - Request body |
| `post(String path, String query, String body)` | POST request with query and body | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `put(String path, String body)` | PUT request with body | `path` - API endpoint path, `body` - Request body |
| `put(String path, String query, String body)` | PUT request with query and body | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `patch(String path, String body)` | PATCH request with body | `path` - API endpoint path, `body` - Request body |
| `patch(String path, String query, String body)` | PATCH request with query and body | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `del(String path)` | DELETE request | `path` - API endpoint path |
| `del(String path, String query)` | DELETE request with query parameters | `path` - API endpoint path, `query` - Query string |

### RestLibApiCall Properties

| Property | Type | Description |
|----------|------|-------------|
| `method` | `HttpVerb` | HTTP method to use (GET, POST, PUT, PATCH, DEL, HEAD) |
| `path` | `String` | API endpoint path |
| `query` | `String` | Query string parameters |
| `body` | `String` | Request body |
| `timeout` | `Integer` | Request timeout in milliseconds (default: 120000) |
| `functionalHeaders` | `Map<String,String>` | Custom headers |

## Configuration

### Named Credentials Setup

This library requires Salesforce Named Credentials for secure API callouts:

1. Go to **Setup** → **Named Credentials**
2. Click **New Named Credential**
3. Configure:
   - **Label**: `My_Named_Credential` (or your preferred name)
   - **URL**: Your API base URL (e.g., `https://api.example.com`)
   - **Identity Type**: Choose appropriate authentication method
   - **Authentication Protocol**: OAuth 2.0, Username/Password, etc.
4. Save and use the Named Credential name in your code

### Default Headers

The library automatically sets these headers:
- `Content-Type: application/json`
- `Accept: application/json`

Custom headers can be added via the `functionalHeaders` property:

```apex
RestLibApiCall apiCall = new RestLibApiCall(HttpVerb.GET, '/api/data', '', '');
apiCall.functionalHeaders = new Map<String, String>{
    'X-API-Key' => 'your-api-key',
    'X-Custom-Header' => 'custom-value'
};
```

## Testing

The library includes comprehensive testing utilities:

```apex
@isTest
public class MyApiClientTest {
    @isTest
    static void testGetUsers() {
        // Set up mock response
        HttpCalloutMockFactory.setMock('My_Named_Credential', 200, '{"users": [{"id": 1, "name": "John"}]}');
        
        // Test your client
        MyApiClient client = new MyApiClient();
        HttpResponse response = client.getUsers();
        
        // Assertions
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('{"users": [{"id": 1, "name": "John"}]}', response.getBody());
    }
    
    @isTest
    static void testCreateUser() {
        // Set up mock response
        HttpCalloutMockFactory.setMock('My_Named_Credential', 201, '{"id": 123, "name": "Jane"}');
        
        // Test
        MyApiClient client = new MyApiClient();
        String userData = '{"name": "Jane", "email": "jane@example.com"}';
        HttpResponse response = client.createUser(userData);
        
        // Assertions
        System.assertEquals(201, response.getStatusCode());
    }
}
```

## Best Practices

1. **🔐 Always use Named Credentials** for production API callouts
2. **🏗️ Extend RestClientLib** rather than using static methods for reusable API clients
3. **⏱️ Handle timeouts appropriately** based on your API's response times
4. **⚡ Use async processing** for non-critical or bulk operations
5. **🛡️ Implement proper error handling** in your finalizer classes
6. **🧪 Write comprehensive tests** using the provided mock factory
7. **📝 Log API calls** for debugging and monitoring
8. **🔄 Implement retry logic** for transient failures

## Requirements

- Salesforce API Version 50.0 or higher
- Named Credentials configured for your target APIs
- Appropriate permissions for HTTP callouts
- Salesforce CLI (for deployment)

## Installation

### Option 1: Install from Package (Recommended)

Download the latest release package and install it in your Salesforce org:

1. **Download the Package**: Click the download link in the Latest Release section above
2. **Install in Salesforce**:
   - Go to **Setup** → **Installed Packages** → **Upload a Package**
   - Upload the downloaded `.zip` file
   - Follow the installation wizard
3. **Configure Named Credentials**: Set up your Named Credentials as described in the Configuration section

### Option 2: Deploy from Source

For development or customization:

1. Clone this repository:
   ```bash
   git clone https://github.com/your-org/RestClientLib.git
   cd RestClientLib
   ```

2. Deploy to your org using Salesforce CLI:
   ```bash
   sf project deploy start --source-dir force-app
   ```

3. Run tests to verify installation:
   ```bash
   sf apex run test --class-names RestLibTests --result-format human
   ```

### Option 3: Install via Salesforce CLI (Coming Soon)

Once the package is published to the AppExchange:

```bash
sf package install --package RestClientLib@1.0.0 --target-org your-org
```

## Release Information

### Current Version: 1.0.0

**Release Date**: TBD  
**Package Size**: ~50KB  
**API Version**: 50.0+  
**Dependencies**: None

### What's Included

- ✅ Core REST client classes (`RestLib`, `RestClient`, `RestClientLib`)
- ✅ Async processing support (`AsyncRestClient`, `AsyncRestLibFinalizer`)
- ✅ HTTP verb enum (`HttpVerb`)
- ✅ API call wrapper (`RestLibApiCall`)
- ✅ Testing utilities (`HttpCalloutMockFactory`, `RestLibTests`)
- ✅ Comprehensive documentation and examples

### Installation Requirements

- Salesforce org with API version 50.0 or higher
- System Administrator or Customize Application permission
- HTTP callout permissions enabled
- Named Credentials configured for your target APIs

### Upgrade Path

This is the initial release (1.0.0). Future updates will be backward compatible and can be installed by downloading the new package version and following the same installation process.

### Support and Documentation

- **GitHub Repository**: [View Source Code](https://github.com/your-org/RestClientLib)
- **Issue Tracker**: [Report Issues](https://github.com/your-org/RestClientLib/issues)
- **Detailed Documentation**: [Package Documentation](docs/PACKAGE-README.md)
- **Examples**: See the Quick Start section above

## Architecture

The library consists of several key components:

### Core Classes
- **`RestLib`**: Base virtual class providing core REST callout functionality
- **`RestClient`**: Static wrapper for making one-off API calls
- **`RestClientLib`**: Extensible wrapper designed to be extended by developers
- **`RestLibApiCall`**: Encapsulates all information needed for an API call
- **`HttpVerb`**: Enum defining supported HTTP methods

### Async Processing
- **`AsyncRestClient`**: Queueable implementation for async REST callouts
- **`AsyncRestLibFinalizer`**: Handles async callout responses

### Testing Support
- **`HttpCalloutMockFactory`**: Factory for creating HTTP callout mocks
- **`RestLibTests`**: Comprehensive test suite

## Contributing

When extending this library, please:
- Follow the existing code patterns
- Add comprehensive tests
- Update documentation as needed
- Use the provided linting and formatting tools

## License

This library is provided as-is for use in Salesforce development projects.

## Support

For detailed API documentation and advanced usage examples, see [Package Documentation](docs/PACKAGE-README.md).