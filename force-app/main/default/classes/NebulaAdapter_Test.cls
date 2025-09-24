@IsTest
private class NebulaAdapter_Test {
    // Simple mock that captures the last request so we can assert on it.
    private class DummyHttpMock implements HttpCalloutMock {
        static HttpRequest lastRequest;

        public HTTPResponse respond(HTTPRequest req) {
            lastRequest = req;

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"ok":true}');
            res.setHeader('Content-Type', 'application/json');
            return res;
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
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        Account a = makeAccount();

        // Build the api call
        RestLibApiCall call = new RestLibApiCall();
        call.method = HttpVerb.POST;
        call.path = '/v1/foo';
        call.encodedQuery = '?x=1';
        call.hasBody = true;
        call.body = '{"hello":"world"}';
        call.functionalHeaders = new Map<String, String>{
            'Content-Type' => 'application/json',
            'X-Custom'     => 'abc123'
        };

        // Create your service instance
        RestClientLib svc = new RestClientLib('My_NC');

        Test.startTest();
        HttpResponse res = svc.makeApiCall(call, a);
        Test.stopTest();

        // Assert — response
        System.assertEquals(200, res.getStatusCode(), 'Should get 200 OK');
        System.assert(res.getBody().contains('"ok":true'));

        // Assert — request captured by mock
        System.assertEquals('POST', DummyHttpMock.lastRequest.getMethod());
        System.assert(DummyHttpMock.lastRequest.getEndpoint().startsWith('callout:'),
                      'Endpoint should use callout:NamedCredential...');
        System.assertEquals('{"hello":"world"}', DummyHttpMock.lastRequest.getBody());
        System.assertEquals('application/json', DummyHttpMock.lastRequest.getHeader('Content-Type'));
        System.assertEquals('abc123', DummyHttpMock.lastRequest.getHeader('X-Custom'));

        // Nebula adapter should safely no-op (no exception thrown)
        NebulaAdapter.info('Just a test log', a);
        NebulaAdapter.logHttpRequest('Req', DummyHttpMock.lastRequest, new List<String>{'X-Custom'}, a);
        NebulaAdapter.logHttpResponse('Res', res, a);
        // If Nebula isn't installed, the above calls should silently do nothing.
    }

    @IsTest
    static void testDeleteRequestNoBodyNoNebulaPresent() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
        Account a = makeAccount();

        RestLibApiCall call = new RestLibApiCall();
        call.method = HttpVerb.DEL; // your code maps DEL -> 'DELETE'
        call.path = '/v1/resource/123';
        call.encodedQuery = '';
        call.hasBody = false;
        call.functionalHeaders = new Map<String, String>{
            'Accept' => 'application/json'
        };

        RestClientLib svc = new RestClientLib('My_NC');

        Test.startTest();
        HttpResponse res = svc.makeApiCall(call, a);
        Test.stopTest();

        // Assert — response
        System.assertEquals(200, res.getStatusCode());

        // Assert — request
        System.assertEquals('DELETE', DummyHttpMock.lastRequest.getMethod(), 'DEL should map to DELETE');
        System.assertEquals('application/json', DummyHttpMock.lastRequest.getHeader('Accept'));
        System.assertEquals(null, DummyHttpMock.lastRequest.getBody(), 'DELETE should not have a body by default');

        // Nebula adapter no-ops again
        NebulaAdapter.debug('Another test log', a);
    }
}
