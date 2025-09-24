# RestClientLib

A comprehensive Salesforce Apex library that provides a clean, type-safe, and extensible framework for making REST API callouts. Built with enterprise security and developer productivity in mind, RestClientLib eliminates the complexity of HTTP callouts while providing powerful features like async processing, comprehensive testing utilities, and fluent API design.

## Latest Release
## Latest Release
<!--LATEST-RELEASE-START-->
<!--LATEST-RELEASE-END-->

## What RestClientLib Does

RestClientLib provides three distinct approaches to REST API integration, each designed for different use cases:

### 1. **RestClientLib** - Extensible API Clients
Extend this virtual class to create dedicated API clients that are locked to specific Named Credentials. Perfect for reusable integrations with external services.

### 2. **RestClient** - Static Utility Methods  
Use static methods for one-off API calls without creating dedicated classes. Ideal for simple integrations and quick prototypes.

### 3. **AsyncRestClient** - Background Processing
Queue API calls for asynchronous execution to avoid governor limits. Essential for high-volume integrations and non-blocking operations.

## Key Features

- **Named Credential Integration**: Secure API callouts using Salesforce's built-in credential management
- **Type-Safe HTTP Verbs**: Strongly-typed enum for HTTP methods (GET, POST, PUT, PATCH, DELETE, HEAD)
- **Fluent API Design**: Chainable methods for building complex API calls
- **Async Processing**: Queueable-based background processing with finalizer pattern
- **Comprehensive Testing**: Built-in mock factory for easy unit testing
- **Automatic Headers**: Default JSON headers with custom header support
- **URL Encoding**: Automatic query parameter encoding
- **PATCH Support**: Handles PATCH requests via POST with `_HttpMethod=PATCH` parameter

## Common Use Cases

### Third-Party API Integrations
Connect Salesforce to external services like payment processors, CRM systems, or marketing platforms.

### Webhook Implementations
Send real-time notifications to external systems when Salesforce records change.

### Data Synchronization
Keep Salesforce data in sync with external databases or applications.

### Analytics and Reporting
Send data to analytics platforms, business intelligence tools, or custom dashboards.

### Microservices Communication
Integrate with microservices architectures and modern API-first applications.

### Rate-Limited API Integration
Manage API rate limits and avoid throttling by using AsyncRestClient for background processing.

## Quick Start

### 1. Extensible API Clients (Recommended)

Create dedicated API clients by extending `RestClientLib`:

```apex
public class SlackApiClient extends RestClientLib {
    public SlackApiClient() {
        super('Slack_Named_Credential');
    }
    
    public HttpResponse sendMessage(String channel, String text) {
        Map<String, Object> message = new Map<String, Object>{
            'channel' => channel,
            'text' => text
        };
        return post('/api/chat.postMessage', JSON.serialize(message));
    }
    
    public HttpResponse getUserInfo(String userId) {
        return get('/api/users.info', 'user=' + userId);
    }
    
    public HttpResponse updateUser(String userId, Map<String, Object> userData) {
        return patch('/api/users/' + userId, JSON.serialize(userData));
    }
    
    // Using the generic makeApiCall method for custom scenarios
    public HttpResponse customRequest(String endpoint, Map<String, String> params) {
        String queryString = '';
        for (String key : params.keySet()) {
            queryString += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8') + '&';
        }
        return makeApiCall(HttpVerb.GET, endpoint, queryString.removeEnd('&'));
    }
}

// Usage
SlackApiClient slack = new SlackApiClient();
HttpResponse response = slack.sendMessage('#general', 'Hello from Salesforce!');
```

### 2. Static Utility Methods

For one-off API calls without creating dedicated classes:

```apex
// Simple GET request
RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.GET, 
    '/api/users', 
    'active=true&limit=10', 
    ''
);
HttpResponse response = RestClient.makeApiCall('MyAPI_Named_Credential', apiCall);

// POST request with custom headers
RestLibApiCall postCall = RestLibApiCall.create()
    .usingPost()
    .withPath('/api/webhooks')
    .withBody(JSON.serialize(webhookData))
    .withHeader('X-API-Key', 'your-api-key')
    .withTimeout(30000);

HttpResponse postResponse = RestClient.makeApiCall('Webhook_Named_Credential', postCall);
```

### 3. Async Processing

For high-volume or non-blocking operations:

```apex
// Create your finalizer class
public class WebhookFinalizer extends AsyncRestLibFinalizer {
    public override void execute(HttpResponse response) {
        if (response.getStatusCode() == 200) {
            System.debug('Webhook sent successfully');
            // Process successful response
        } else {
            System.debug('Webhook failed: ' + response.getBody());
            // Handle error or retry logic
        }
    }
}

// Queue the async call
RestLibApiCall apiCall = RestLibApiCall.create()
    .usingPost()
    .withPath('/api/webhooks')
    .withBody(JSON.serialize(webhookData));

System.enqueueJob(new AsyncRestClient(
    'Webhook_Named_Credential', 
    apiCall, 
    WebhookFinalizer.class
));
```

## API Reference

### RestClientLib Methods (Protected - Extend to Use)

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
| `makeApiCall(HttpVerb method, String path)` | Generic API call with method and path | `method` - HTTP verb, `path` - API endpoint path |
| `makeApiCall(HttpVerb method, String path, String query)` | Generic API call with method, path, and query | `method` - HTTP verb, `path` - API endpoint path, `query` - Query string |
| `makeApiCall(HttpVerb method, String path, String query, String body)` | Generic API call with all parameters | `method` - HTTP verb, `path` - API endpoint path, `query` - Query string, `body` - Request body |

### RestClient Static Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `makeApiCall(String namedCredential, RestLibApiCall apiCall)` | Make a REST callout | `namedCredential` - Named Credential name, `apiCall` - API call configuration |

### RestLibApiCall Fluent API

| Method | Description | Returns |
|--------|-------------|---------|
| `create()` | Create new API call instance | `RestLibApiCall` |
| `withMethod(HttpVerb method)` | Set HTTP method (generic) | `RestLibApiCall` |
| `usingGet()` | Set HTTP method to GET | `RestLibApiCall` |
| `usingPost()` | Set HTTP method to POST | `RestLibApiCall` |
| `usingPut()` | Set HTTP method to PUT | `RestLibApiCall` |
| `usingPatch()` | Set HTTP method to PATCH | `RestLibApiCall` |
| `usingDelete()` | Set HTTP method to DELETE | `RestLibApiCall` |
| `usingHead()` | Set HTTP method to HEAD | `RestLibApiCall` |
| `withPath(String path)` | Set API endpoint path | `RestLibApiCall` |
| `withQuery(String query)` | Set query parameters | `RestLibApiCall` |
| `withBody(String body)` | Set request body | `RestLibApiCall` |
| `withHeaders(Map<String,String> headers)` | Set custom headers | `RestLibApiCall` |
| `withHeader(String key, String value)` | Add single header | `RestLibApiCall` |
| `withTimeout(Integer timeout)` | Set timeout in milliseconds | `RestLibApiCall` |

### RestLibApiCall Constructors

| Constructor | Description | Parameters |
|-------------|-------------|------------|
| `RestLibApiCall(HttpVerb method, String path, String query, String body)` | Basic constructor with default headers | `method` - HTTP verb, `path` - API path, `query` - Query string, `body` - Request body |
| `RestLibApiCall(HttpVerb method, String path, String query, String body, Map<String,String> headers)` | Full constructor with custom headers | `method` - HTTP verb, `path` - API path, `query` - Query string, `body` - Request body, `headers` - Custom headers |

### HttpVerb Enum

| Value | Description |
|-------|-------------|
| `GET` | HTTP GET method |
| `POST` | HTTP POST method |
| `PUT` | HTTP PUT method |
| `PATCH` | HTTP PATCH method (converted to POST with `_HttpMethod=PATCH`) |
| `DEL` | HTTP DELETE method |
| `HEAD` | HTTP HEAD method |

## Method Reference

### When to Use Each Approach

| Method | Use Case | Benefits | Example |
|--------|----------|----------|---------|
| **Extend RestClientLib** | Reusable API clients for specific services | Type-safe, locked to Named Credential, easy to test | `SlackApiClient`, `StripeApiClient` |
| **RestClient.makeApiCall()** | One-off API calls, quick prototypes | No class creation needed, simple static calls | Webhooks, notifications, simple integrations |
| **RestLibApiCall fluent API** | Complex API calls with custom headers/timeouts | Chainable methods, readable code, flexible | Custom authentication, complex payloads |
| **AsyncRestClient** | High-volume operations, non-blocking calls | Avoids governor limits, background processing | Bulk data sync, non-critical notifications |
| **HttpCalloutMockFactory** | Unit testing API integrations | Easy mocking, multiple response scenarios | Test success/error cases, edge conditions |

### Method Comparison

| Feature | RestClientLib | RestClient | RestLibApiCall | AsyncRestClient |
|---------|---------------|------------|----------------|-----------------|
| **Named Credential** | Required in constructor | Required per call | Required per call | Required in constructor |
| **Type Safety** | High (protected methods) | Medium (static methods) | High (fluent API) | High (constructor) |
| **Reusability** | High (extend once) | Low (per call) | Medium (reuse instances) | High (queue multiple) |
| **Testing** | Easy (mock once) | Easy (mock per call) | Easy (mock per call) | Medium (test finalizer) |
| **Governor Limits** | Subject to callout limits | Subject to callout limits | Subject to callout limits | Avoids callout limits |
| **Complexity** | Low (simple methods) | Low (static calls) | Medium (fluent chaining) | Medium (finalizer pattern) |

## Testing

RestClientLib includes comprehensive testing utilities through the `HttpCalloutMockFactory` class:

### Basic Mock Setup

```apex
@isTest
public class MyApiClientTest {
    @isTest
    static void testGetUsers() {
        // Set up mock response
        HttpCalloutMockFactory.setMock('MyAPI_Named_Credential', 200, 'OK', '{"users": [{"id": 1, "name": "John"}]}', new Map<String, String>());
        
        // Test your client
        MyApiClient client = new MyApiClient();
        HttpResponse response = client.getUsers();
        
        // Assertions
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('{"users": [{"id": 1, "name": "John"}]}', response.getBody());
    }
    
    @isTest
    static void testMultipleCallouts() {
        // Set up multiple mock responses
        List<HttpResponse> responses = new List<HttpResponse>{
            HttpCalloutMockFactory.generateHttpResponse(200, 'OK', '{"users": []}', new Map<String, String>()),
            HttpCalloutMockFactory.generateHttpResponse(201, 'Created', '{"id": 123}', new Map<String, String>())
        };
        
        HttpCalloutMockFactory.setMock('MyAPI_Named_Credential', responses);
        
        // Test multiple calls
        MyApiClient client = new MyApiClient();
        HttpResponse getResponse = client.getUsers();
        HttpResponse postResponse = client.createUser('{"name": "Jane"}');
        
        System.assertEquals(200, getResponse.getStatusCode());
        System.assertEquals(201, postResponse.getStatusCode());
    }
}
```

### Testing Async Operations

```apex
@isTest
public class WebhookFinalizerTest {
    @isTest
    static void testSuccessfulWebhook() {
        // Set up mock
        HttpCalloutMockFactory.setMock('Webhook_Named_Credential', 200, 'OK', '{"status": "success"}', new Map<String, String>());
        
        // Test finalizer
        Test.startTest();
        WebhookFinalizer finalizer = new WebhookFinalizer();
        finalizer.response = HttpCalloutMockFactory.generateHttpResponse(200, 'OK', '{"status": "success"}', new Map<String, String>());
        finalizer.execute(finalizer.response);
        Test.stopTest();
        
        // Verify behavior
        System.assertEquals(200, finalizer.response.getStatusCode());
    }
}
```

## Installation

### Option 1: Install Package (Recommended)

1. **Install**: Click the install link in the Latest Release section above
2. **Configure**: Set up Named Credentials for your APIs

### Option 2: Deploy from Source

```bash
git clone https://github.com/your-org/RestClientLib.git
cd RestClientLib
sf project deploy start --source-dir force-app
```

## Requirements

- Named Credentials configured

## Package Information

### What's Included

- **RestLib** - Base virtual class with core REST callout functionality
- **RestClient** - Static wrapper for one-off API calls
- **RestClientLib** - Extensible virtual class for creating API clients
- **RestLibApiCall** - Fluent API builder for complex API calls
- **HttpVerb** - Type-safe enum for HTTP methods
- **AsyncRestClient** - Queueable implementation for async processing
- **AsyncRestLibFinalizer** - Abstract class for handling async responses
- **HttpCalloutMockFactory** - Comprehensive testing utilities
- **RestLibTests** - Complete test suite

### Package Details

- **Size**: ~50KB
- **API Version**: 50.0+
- **Dependencies**: None
- **Installation**: Upload package zip file

### Architecture

RestClientLib follows a layered architecture:

1. **RestLib** - Core functionality and HTTP request handling
2. **RestClient** - Static utility layer for simple use cases
3. **RestClientLib** - Extensible layer for dedicated API clients
4. **RestLibApiCall** - Fluent API builder for complex scenarios
5. **AsyncRestClient** - Queueable layer for background processing

### Support

- **GitHub**: [View Source Code](https://github.com/your-org/RestClientLib)
- **Issues**: [Report Problems](https://github.com/your-org/RestClientLib/issues)

## License

This package is provided as-is for use in Salesforce development projects.
