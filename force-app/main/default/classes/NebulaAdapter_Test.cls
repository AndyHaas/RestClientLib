@IsTest
private class NebulaAdapter_Test {
    // Mock that implements HttpCalloutMock and uses HttpCalloutMockFactory for response generation
    public class RequestCapturingMock implements HttpCalloutMock {
        public HttpRequest lastRequest;
        private HttpResponse mockResponse;

        @SuppressWarnings('PMD.ExcessiveParameterList')
        public RequestCapturingMock(Integer code, String status, String bodyAsString, Map<String, String> headers) {
            this.mockResponse = HttpCalloutMockFactory.generateHttpResponse(code, status, bodyAsString, headers);
        }

        public HttpResponse respond(HttpRequest req) {
            lastRequest = req;
            return mockResponse;
        }
    }

    // Helper to create a minimal related record for logging.
    private static Account makeAccount() {
        Account a = new Account(Name = 'Test Acct');
        insert a;
        return a;
    }

    @IsTest
    static void testPostRequestNoNebulaPresent() {
        // Arrange
        RequestCapturingMock mock = new RequestCapturingMock(
            200,
            'OK',
            '{"ok":true}',
            new Map<String, String>{'Content-Type' => 'application/json'}
        );
        Test.setMock(HttpCalloutMock.class, mock);
        Account a = makeAccount();

        // Build the api call
        RestLibApiCall call = new RestLibApiCall(
            HttpVerb.POST,
            '/v1/foo',
            '?x=1',
            '{"hello":"world"}',
            new Map<String, String>{
                'Content-Type' => 'application/json',
                'X-Custom'     => 'abc123'
            }
        );

        // Create your service instance
        RestClientLib svc = new RestClientLib('My_NC');

        Test.startTest();
        HttpResponse res = svc.makeApiCall(call, a);
        Test.stopTest();

        // Assert — response
        System.assertEquals(200, res.getStatusCode(), 'Should get 200 OK');
        System.assert(res.getBody().contains('"ok":true'), 'Response body should contain ok:true');

        // Assert — request captured by mock
        System.assertEquals('POST', mock.lastRequest.getMethod(), 'Should use POST method');
        System.assert(mock.lastRequest.getEndpoint().startsWith('callout:'),
                      'Endpoint should use callout:NamedCredential...');
        System.assertEquals('{"hello":"world"}', mock.lastRequest.getBody(), 'Should have correct body');
        System.assertEquals('application/json', mock.lastRequest.getHeader('Content-Type'), 'Should have correct Content-Type');
        System.assertEquals('abc123', mock.lastRequest.getHeader('X-Custom'), 'Should have correct X-Custom header');

        // Nebula adapter should safely no-op (no exception thrown)
        NebulaAdapter.info('Just a test log', a);
        NebulaAdapter.logHttpRequest('Req', mock.lastRequest, new List<String>{'X-Custom'}, a);
        NebulaAdapter.logHttpResponse('Res', res, a);
        // If Nebula isn't installed, the above calls should silently do nothing.
    }

    @IsTest
    static void testDeleteRequestNoBodyNoNebulaPresent() {
        // Arrange
        RequestCapturingMock mock = new RequestCapturingMock(
            200,
            'OK',
            '{"ok":true}',
            new Map<String, String>{'Content-Type' => 'application/json'}
        );
        Test.setMock(HttpCalloutMock.class, mock);
        Account a = makeAccount();

        RestLibApiCall call = new RestLibApiCall(
            HttpVerb.DEL, // your code maps DEL -> 'DELETE'
            '/v1/resource/123',
            '',
            '',
            new Map<String, String>{
                'Accept' => 'application/json'
            }
        );

        RestClientLib svc = new RestClientLib('My_NC');

        Test.startTest();
        HttpResponse res = svc.makeApiCall(call, a);
        Test.stopTest();

        // Assert — response
        System.assertEquals(200, res.getStatusCode(), 'Should get 200 OK');

        // Assert — request
        System.assertEquals('DELETE', mock.lastRequest.getMethod(), 'DEL should map to DELETE');
        System.assertEquals('application/json', mock.lastRequest.getHeader('Accept'), 'Should have correct Accept header');
        System.assert(String.isBlank(mock.lastRequest.getBody()), 'DELETE should not have a body by default');

        // Nebula adapter no-ops again
        NebulaAdapter.debug('Another test log', a);
    }

    @IsTest
    static void testNebulaAdapterAvailability() {
        // Test isAvailable method
        Boolean isAvailable = NebulaAdapter.isAvailable();
        System.assert(!isAvailable, 'Nebula should not be available in test context');
    }

    @IsTest
    static void testNebulaAdapterErrorLogging() {
        Account a = makeAccount();
        Exception testEx = new DmlException('Test exception');
        
        // Test error logging without Nebula
        Test.startTest();
        NebulaAdapter.error('Test error message', a, testEx);
        Test.stopTest();
        
        // Should not throw exception, just fall back to System.debug
        System.assert(true, 'Error logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterErrorLoggingWithoutRecord() {
        Exception testEx = new DmlException('Test exception');
        
        // Test error logging without record
        Test.startTest();
        NebulaAdapter.error('Test error message', null, testEx);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Error logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterErrorLoggingWithoutException() {
        Account a = makeAccount();
        
        // Test error logging without exception
        Test.startTest();
        NebulaAdapter.error('Test error message', a, null);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Error logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterHttpRequestLogging() {
        Account a = makeAccount();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://test.com/api');
        req.setBody('{"test":"data"}');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer token123');
        
        List<String> headersToLog = new List<String>{'Content-Type', 'Authorization'};
        
        Test.startTest();
        NebulaAdapter.logHttpRequest('Test Request', req, headersToLog, a);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'HTTP request logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterHttpRequestLoggingWithoutHeaders() {
        Account a = makeAccount();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://test.com/api');
        
        Test.startTest();
        NebulaAdapter.logHttpRequest('Test Request', req, null, a);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'HTTP request logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterHttpResponseLogging() {
        Account a = makeAccount();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody('{"success":true}');
        
        Test.startTest();
        NebulaAdapter.logHttpResponse('Test Response', res, a);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'HTTP response logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterHttpResponseLoggingWithoutBody() {
        Account a = makeAccount();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(404);
        res.setStatus('Not Found');
        
        Test.startTest();
        NebulaAdapter.logHttpResponse('Test Response', res, a);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'HTTP response logging should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterSave() {
        Test.startTest();
        NebulaAdapter.save();
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Save should complete without exception');
    }

    @IsTest
    static void testNebulaAdapterLoggingWithoutRecord() {
        Test.startTest();
        NebulaAdapter.info('Test message', null);
        NebulaAdapter.debug('Test debug message', null);
        Test.stopTest();
        
        // Should not throw exception
        System.assert(true, 'Logging without record should complete without exception');
    }
}
