# RestClientLib

A comprehensive Salesforce Apex library for making REST API callouts with ease, security, and reliability. This package provides a robust foundation for building REST integrations in Salesforce with built-in support for Named Credentials, async processing, and comprehensive testing utilities.

## Features

- **Named Credential Integration**: Secure API callouts using Salesforce Named Credentials
- **Convenient HTTP Methods**: Simple `get()`, `post()`, `put()`, `patch()`, and `del()` methods
- **Async Processing**: Queueable-based async REST callouts with finalizer pattern
- **Comprehensive Testing**: Built-in mock factory and test utilities
- **Type Safety**: Strongly typed HTTP verbs and API call objects
- **Error Handling**: Robust error handling and timeout management
- **Extensible Design**: Virtual classes designed for easy extension

## Architecture

The library consists of several key components:

### Core Classes

- **`RestLib`**: Base virtual class providing the core REST callout functionality
- **`RestClient`**: Static wrapper for making one-off API calls
- **`RestClientLib`**: Extensible wrapper designed to be extended by developers
- **`RestLibApiCall`**: Encapsulates all information needed for an API call
- **`HttpVerb`**: Enum defining supported HTTP methods (GET, POST, PUT, PATCH, HEAD, DEL)

### Async Processing

- **`AsyncRestClient`**: Queueable implementation for async REST callouts
- **`AsyncRestLibFinalizer`**: Handles async callout responses

### Testing Support

- **`HttpCalloutMockFactory`**: Factory for creating HTTP callout mocks
- **`RestLibTests`**: Comprehensive test suite

## Quick Start

### Basic Usage

```apex
// Extend RestClientLib for your specific API
public class MyApiClient extends RestClientLib {
    public MyApiClient() {
        super('My_Named_Credential');
    }
    
    public HttpResponse getUsers() {
        return get('/users');
    }
    
    public HttpResponse createUser(String userData) {
        return post('/users', '', userData);
    }
}

// Usage
MyApiClient client = new MyApiClient();
HttpResponse response = client.getUsers();
```

### Static Usage

```apex
// For one-off calls
RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.GET, 
    '/api/users', 
    '?active=true', 
    ''
);
HttpResponse response = RestClient.makeApiCall('My_Named_Credential', apiCall);
```

### Async Usage

```apex
// For async processing
RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.POST, 
    '/api/webhooks', 
    '', 
    JSON.serialize(webhookData)
);
System.enqueueJob(new AsyncRestClient('My_Named_Credential', apiCall, MyWebhookFinalizer.class));
```

## API Reference

### RestClientLib Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `get(String path)` | GET request to specified path | `path` - API endpoint path |
| `get(String path, String query)` | GET request with query parameters | `path` - API endpoint path, `query` - Query string |
| `post(String path, String query, String body)` | POST request | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `put(String path, String query, String body)` | PUT request | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `patch(String path, String query, String body)` | PATCH request | `path` - API endpoint path, `query` - Query string, `body` - Request body |
| `del(String path)` | DELETE request | `path` - API endpoint path |
| `del(String path, String query)` | DELETE request with query parameters | `path` - API endpoint path, `query` - Query string |

### RestLibApiCall Properties

| Property | Type | Description |
|----------|------|-------------|
| `method` | `HttpVerb` | HTTP method to use |
| `path` | `String` | API endpoint path |
| `query` | `String` | Query string parameters |
| `body` | `String` | Request body |
| `timeout` | `Integer` | Request timeout in milliseconds (default: 120000) |
| `functionalHeaders` | `Map<String,String>` | Custom headers |

## Configuration

### Named Credentials

This library requires Salesforce Named Credentials for secure API callouts. Set up your Named Credential with:

1. Go to Setup → Named Credentials
2. Create a new Named Credential
3. Configure the endpoint URL and authentication
4. Use the Named Credential name in your RestClientLib constructor

### Default Headers

The library sets these default headers:
- `Content-Type: application/json`
- `Accept: application/json`

Custom headers can be added via the `functionalHeaders` property of `RestLibApiCall`.

## Testing

The library includes comprehensive testing utilities:

```apex
@isTest
public class MyApiClientTest {
    @isTest
    static void testGetUsers() {
        // Set up mock
        HttpCalloutMockFactory.setMock('My_Named_Credential', 200, '{"users": []}');
        
        // Test
        MyApiClient client = new MyApiClient();
        HttpResponse response = client.getUsers();
        
        // Assertions
        System.assertEquals(200, response.getStatusCode());
    }
}
```

## Best Practices

1. **Always use Named Credentials** for production API callouts
2. **Extend RestClientLib** rather than using static methods for reusable API clients
3. **Handle timeouts appropriately** based on your API's response times
4. **Use async processing** for non-critical or bulk operations
5. **Implement proper error handling** in your finalizer classes
6. **Write comprehensive tests** using the provided mock factory

## Requirements

- Salesforce API Version 50.0 or higher
- Named Credentials configured for your target APIs
- Appropriate permissions for HTTP callouts

## Installation

1. Deploy the classes to your Salesforce org
2. Configure your Named Credentials
3. Extend `RestClientLib` for your specific API needs
4. Write tests using the provided utilities

## License

This library is provided as-is for use in Salesforce development projects.

## Contributing

When extending this library, please:
- Follow the existing code patterns
- Add comprehensive tests
- Update documentation as needed
- Use the provided linting and formatting tools