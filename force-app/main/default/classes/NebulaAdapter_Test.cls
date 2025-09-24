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
}
