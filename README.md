# RestClientLib

A powerful Salesforce Apex package that simplifies REST API integrations with enterprise-grade security, reliability, and ease of use. Perfect for connecting Salesforce to external systems, webhooks, and third-party APIs.

## Latest Release
<!--LATEST-RELEASE-START-->
_No release yet_
<!--LATEST-RELEASE-END-->

## Why RestClientLib?

Building REST integrations in Salesforce can be complex and error-prone. RestClientLib eliminates the boilerplate code and provides:

- **Enterprise Security**: Built-in Named Credential support for secure API callouts
- **Developer Productivity**: Simple, intuitive methods for all HTTP operations
- **Scalable Architecture**: Async processing for high-volume integrations
- **Test-Ready**: Comprehensive testing utilities and mock support
- **Production-Ready**: Robust error handling and timeout management
- **Extensible**: Easy to customize for your specific API needs

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

## Quick Start

### Simple API Client

Create a client for your specific API:

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
        return get('/api/users.info?user=' + userId);
    }
}

// Usage
SlackApiClient slack = new SlackApiClient();
HttpResponse response = slack.sendMessage('#general', 'Hello from Salesforce!');
```

### One-off API Calls

For simple, one-time API calls:

```apex
// Send webhook notification
Map<String, Object> webhookData = new Map<String, Object>{
    'event' => 'lead.created',
    'leadId' => lead.Id,
    'email' => lead.Email
};

RestLibApiCall apiCall = new RestLibApiCall(
    HttpVerb.POST, 
    '/webhooks/leads', 
    '', 
    JSON.serialize(webhookData)
);
HttpResponse response = RestClient.makeApiCall('Webhook_Named_Credential', apiCall);
```

### Async Processing

For non-blocking operations:

```apex
// Queue webhook for background processing
System.enqueueJob(new AsyncRestClient(
    'Webhook_Named_Credential', 
    apiCall, 
    WebhookFinalizer.class
));
```

## Key Features

### Simple HTTP Methods
- `get(path)` - GET requests
- `post(path, body)` - POST requests  
- `put(path, body)` - PUT requests
- `patch(path, body)` - PATCH requests
- `del(path)` - DELETE requests

### Async Processing
Queue API calls for background processing to avoid governor limits.

### Built-in Testing
Comprehensive mock factory for easy unit testing.

### Enterprise Security
Full Named Credential support for secure API callouts.

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

- **9 Apex Classes** for comprehensive REST API integration
- **Named Credential Support** for secure API callouts
- **Async Processing** for high-volume operations
- **Testing Utilities** with mock factory
- **Complete Documentation** and examples

### Package Details

- **Size**: ~50KB
- **API Version**: 50.0+
- **Dependencies**: None
- **Installation**: Upload package zip file

### Support

- **GitHub**: [View Source Code](https://github.com/your-org/RestClientLib)
- **Issues**: [Report Problems](https://github.com/your-org/RestClientLib/issues)

## License

This package is provided as-is for use in Salesforce development projects.