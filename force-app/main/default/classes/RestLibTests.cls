@isTest
private class RestLibTests {
	/**
	 * @description Executes a positive test case of the Constructor.
	 * Expects the named credential to be set.
	 */
	@isTest
	private static void testConstructorPositive() {
		RestClient rc;

		Test.startTest();
		rc = new RestClient('dummyNamedCredential');
		Test.stopTest();

		Assert.areEqual(
			'dummyNamedCredential',
			rc.namedCredentialName,
			'Expected the name credential to match'
		);
	}

	/**
	 * @description Tests the fluent interface for RestLibApiCall with GET
	 */
	@isTest
	private static void testRestLibApiCallFluentInterface() {
		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingGet()
			.withPath('/test')
			.withQuery('param=value')
			.withHeader('Test-Header', 'TestValue');
		Test.stopTest();

		Assert.areEqual(HttpVerb.GET, apiCall.method, 'Method should be GET');
		Assert.areEqual(
			'/test/',
			apiCall.path,
			'Path should be /test/ with trailing slash'
		);
		Assert.areEqual(
			'param=value',
			apiCall.query,
			'Query should be set correctly'
		);
		Assert.isTrue(
			apiCall.functionalHeaders.containsKey('Test-Header'),
			'Custom header should be present'
		);
		Assert.areEqual(
			'TestValue',
			apiCall.functionalHeaders.get('Test-Header'),
			'Header value should match'
		);
	}

	/**
	 * @description Tests the fluent interface for RestLibApiCall with POST and body
	 */
	@isTest
	private static void testRestLibApiCallFluentInterfaceWithPost() {
		String testBody = '{"test":"value"}';

		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingPost()
			.withPath('/resource')
			.withBody(testBody)
			.withHeaders(
				new Map<String, String>{
					'Content-Type' => 'application/json',
					'X-Custom' => 'CustomValue'
				}
			);
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, apiCall.method, 'Method should be POST');
		Assert.areEqual(
			'/resource/',
			apiCall.path,
			'Path should be /resource/ with trailing slash'
		);
		Assert.areEqual(testBody, apiCall.body, 'Body should be set correctly');
		Assert.isTrue(apiCall.hasBody, 'hasBody should be true for POST with body');
		Assert.areEqual(
			'CustomValue',
			apiCall.functionalHeaders.get('X-Custom'),
			'Custom header should be set'
		);
		Assert.areEqual(
			'application/json',
			apiCall.functionalHeaders.get('Content-Type'),
			'Content-Type should be set'
		);
	}

	/**
	 * @description Tests the fluent interface for RestLibApiCall with PATCH (which is handled specially)
	 */
	@isTest
	private static void testRestLibApiCallFluentInterfaceWithPatch() {
		String testBody = '{"field":"newValue"}';

		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingPatch()
			.withPath('/resource/123')
			.withBody(testBody);
		Test.stopTest();

		// PATCH is converted to POST with special parameters
		Assert.areEqual(
			HttpVerb.POST,
			apiCall.method,
			'Method should be POST when using PATCH'
		);
		Assert.areEqual(
			'/resource/123/',
			apiCall.path,
			'Path should be correct with trailing slash'
		);
		Assert.areEqual(testBody, apiCall.body, 'Body should be set correctly');
		Assert.isTrue(
			apiCall.hasBody,
			'hasBody should be true for PATCH with body'
		);
		Assert.isTrue(
			apiCall.encodedQuery.contains('_HttpMethod=PATCH'),
			'Should have PATCH parameter in query'
		);
	}

	/**
	 * Note: we do not have a constructor test for the no param
	 * constructor. Because it's access modifier is protected
	 * we cannot use that constructor - the compiler throws an error
	 * noting the method is not visible
	 */

	/**
	 * @description Executes a positive test case against the RestClients'
	 * makeApiCall method, this time specifying all the method params
	 */
	@isTest
	private static void testStaticMakeApiCallFullParamsPositive() {
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = RestClient.makeApiCall(
			'DummyNamedCredential',
			new RestLibApiCall(HttpVerb.GET, '/', '', '', null)
		);
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected the return status code to be 200'
		);
	}

	@isTest
	private static void testStaticMakeApiCallNoHeadersOrBodyParamsPositive() {
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = RestClient.makeApiCall(
			'DummyNamedCredential',
			new RestLibApiCall(HttpVerb.GET, '/', '', '')
		);
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected the return status code to be 200'
		);
	}

	@isTest
	private static void testStaticMakeApiCallNoHeadersOrBodyOrQueryParamsPositive() {
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		RestLibApiCall call = new RestLibApiCall(HttpVerb.GET, '/', '', '');
		HttpResponse response = RestClient.makeApiCall(
			'DummyNamedCredential',
			call
		);
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected the return status code to be 200'
		);
	}

	/**
	 * Convenience, Instance Methods
	 * These 6 methods are not utilized by our API service
	 * class.
	 */

	/**
	 * @description Positive test case for convenience method needing only
	 * path and query params.
	 */
	@isTest
	private static void testGetWithPathAndQueryPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.get('/', '?test');
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected to get the 200 response code'
		);
	}

	/**
	 * @description Positive test case for convenience method needing only
	 * path and query params.
	 */
	@isTest
	private static void testGetWithPathPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.get('/');
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected to get the 200 response code'
		);
	}

	@isTest
	private static void testDelWithPathPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.del('/');
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected to get the 200 response code'
		);
	}

	@isTest
	private static void testDelWithPathAndQueryPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.del('/', 'foo');
		Test.stopTest();

		Assert.areEqual(
			200,
			response.getStatusCode(),
			'Expected to get the 200 response code'
		);
	}

	@isTest
	private static void testPostWithPathAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.post('/', '{"Id": "003ae3fn12df25k309"}');
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testPostWithPathQueryAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.post('/', '', '{"Id": "003ae3fn12df25k309"}');
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testPutWithPathAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.put('/', '{"Id": "003ae3fn12df25k309"}');
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testPutWithPathQueryAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.put('/', '', '{"Id": "003ae3fn12df25k309"}');
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testPatchWithPathQueryAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.patch(
			'/',
			'q=foo',
			'{"Id": "003ae3fn12df25k309"}'
		);
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testPatchWithPathAndBodyPositive() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			201,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		HttpResponse response = rc.patch('/', '{"Id": "003ae3fn12df25k309"}');
		Test.stopTest();

		Assert.areEqual(
			201,
			response.getStatusCode(),
			'Expected to get the 201 response code'
		);
	}

	@isTest
	private static void testProtectedRestLibConstructorPositive() {
		RestLib rl = new RestLib();
		Assert.areNotEqual(null, rl, 'Expected the RestLib to be created');
	}

	@isTest
	private static void testEnsureStringEndsInSlashPositiveStartWithoutSlash() {
		RestLibApiCall rlac = new RestLibApiCall();
		Test.startTest();
		String result = RestLibApiCall.ensureStringEndsInSlash('noSlash');
		Test.stopTest();
		Assert.isTrue(
			result.endsWith('/'),
			'Expected the result to end with a slash'
		);
	}

	@isTest
	private static void testEnsureStringEndsInSlashAlreadyHasSlash() {
		Test.startTest();
		String result = RestLibApiCall.ensureStringEndsInSlash('alreadySlash/');
		Test.stopTest();
		Assert.areEqual('alreadySlash/', result, 'Should return unchanged when already ends with slash');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceWithDelete() {
		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingDelete()
			.withPath('/resource/123')
			.withQuery('param=value');
		Test.stopTest();

		Assert.areEqual(HttpVerb.DEL, apiCall.method, 'Method should be DEL');
		Assert.areEqual('/resource/123/', apiCall.path, 'Path should be correct');
		Assert.areEqual('param=value', apiCall.query, 'Query should be set');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceWithHead() {
		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingHead()
			.withPath('/status')
			.withHeader('Custom-Header', 'Value');
		Test.stopTest();

		Assert.areEqual(HttpVerb.HEAD, apiCall.method, 'Method should be HEAD');
		Assert.areEqual('/status/', apiCall.path, 'Path should be correct');
		Assert.areEqual('Value', apiCall.functionalHeaders.get('Custom-Header'), 'Custom header should be set');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceWithTimeout() {
		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingGet()
			.withPath('/test')
			.withTimeout(5000);
		Test.stopTest();

		Assert.areEqual(5000, apiCall.timeout, 'Timeout should be set to 5000ms');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceWithHeaders() {
		Map<String, String> customHeaders = new Map<String, String>{
			'Authorization' => 'Bearer token123',
			'X-API-Key' => 'key456'
		};

		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingPost()
			.withPath('/api')
			.withHeaders(customHeaders);
		Test.stopTest();

		Assert.areEqual('Bearer token123', apiCall.functionalHeaders.get('Authorization'), 'Authorization header should be set');
		Assert.areEqual('key456', apiCall.functionalHeaders.get('X-API-Key'), 'API key header should be set');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceWithSingleHeader() {
		Test.startTest();
		RestLibApiCall apiCall = RestLibApiCall.create()
			.usingGet()
			.withPath('/test')
			.withHeader('Accept', 'application/xml')
			.withHeader('User-Agent', 'MyApp/1.0');
		Test.stopTest();

		Assert.areEqual('application/xml', apiCall.functionalHeaders.get('Accept'), 'Accept header should be set');
		Assert.areEqual('MyApp/1.0', apiCall.functionalHeaders.get('User-Agent'), 'User-Agent header should be set');
	}

	@isTest
	private static void testRestLibApiCallMethodStringProperty() {
		Test.startTest();
		RestLibApiCall getCall = RestLibApiCall.create().usingGet();
		RestLibApiCall delCall = RestLibApiCall.create().usingDelete();
		Test.stopTest();

		Assert.areEqual('GET', getCall.methodString, 'GET method string should be GET');
		Assert.areEqual('DELETE', delCall.methodString, 'DEL method string should be DELETE');
	}

	@isTest
	private static void testRestLibApiCallHasBodyProperty() {
		Test.startTest();
		RestLibApiCall postWithBody = RestLibApiCall.create()
			.usingPost()
			.withBody('{"test":"data"}');
		RestLibApiCall getWithoutBody = RestLibApiCall.create()
			.usingGet();
		RestLibApiCall putWithBody = RestLibApiCall.create()
			.usingPut()
			.withBody('{"update":"data"}');
		Test.stopTest();

		Assert.isTrue(postWithBody.hasBody, 'POST with body should have hasBody=true');
		Assert.isFalse(getWithoutBody.hasBody, 'GET without body should have hasBody=false');
		Assert.isTrue(putWithBody.hasBody, 'PUT with body should have hasBody=true');
	}

	@isTest
	private static void testRestLibApiCallPathHandling() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create().withPath('noSlash');
		RestLibApiCall call2 = RestLibApiCall.create().withPath('/withSlash');
		RestLibApiCall call3 = RestLibApiCall.create().withPath('');
		Test.stopTest();

		Assert.areEqual('/noSlash/', call1.path, 'Path without slash should get leading and trailing slashes');
		Assert.areEqual('/withSlash/', call2.path, 'Path with leading slash should get trailing slash');
		Assert.areEqual('/', call3.path, 'Empty path should default to /');
	}

	@isTest
	private static void testRestLibApiCallQueryHandling() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create().withQuery('param=value');
		RestLibApiCall call2 = RestLibApiCall.create().withQuery('?prefixed');
		RestLibApiCall call3 = RestLibApiCall.create().withQuery('');
		Test.stopTest();

		Assert.areEqual('param=value', call1.query, 'Query should be stored as-is');
		Assert.areEqual('?prefixed', call1.encodedQuery, 'Query should be prefixed with ?');
		Assert.areEqual('?prefixed', call2.encodedQuery, 'Pre-prefixed query should remain unchanged');
		Assert.areEqual(null, call3.encodedQuery, 'Empty query should return null for encodedQuery');
	}

	@isTest
	private static void testRestLibApiCallDefaultHeaders() {
		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create();
		Test.stopTest();

		Assert.areEqual('application/json', call.functionalHeaders.get('Content-Type'), 'Should have default Content-Type');
		Assert.areEqual('application/json', call.functionalHeaders.get('Accept'), 'Should have default Accept');
	}

	@isTest
	private static void testRestLibApiCallConstructorWithAllParams() {
		Map<String, String> headers = new Map<String, String>{'Custom' => 'Value'};
		
		Test.startTest();
		RestLibApiCall call = new RestLibApiCall(
			HttpVerb.POST,
			'/test',
			'param=value',
			'{"data":"test"}',
			headers
		);
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, call.method, 'Method should be POST');
		Assert.areEqual('/test/', call.path, 'Path should be correct');
		Assert.areEqual('param=value', call.query, 'Query should be set');
		Assert.areEqual('{"data":"test"}', call.body, 'Body should be set');
		Assert.areEqual('Value', call.functionalHeaders.get('Custom'), 'Custom header should be set');
	}

	@isTest
	private static void testRestLibApiCallConstructorWithoutHeaders() {
		Test.startTest();
		RestLibApiCall call = new RestLibApiCall(
			HttpVerb.GET,
			'/api',
			'id=123',
			''
		);
		Test.stopTest();

		Assert.areEqual(HttpVerb.GET, call.method, 'Method should be GET');
		Assert.areEqual('/api/', call.path, 'Path should be correct');
		Assert.areEqual('id=123', call.query, 'Query should be set');
		Assert.areEqual('', call.body, 'Body should be empty');
		Assert.areEqual('application/json', call.functionalHeaders.get('Content-Type'), 'Should use default headers');
	}

	@isTest
	private static void testRestLibApiCallPatchConstructor() {
		Test.startTest();
		RestLibApiCall call = new RestLibApiCall(
			HttpVerb.PATCH,
			'/resource/123',
			'param=value',
			'{"update":"data"}'
		);
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, call.method, 'PATCH should be converted to POST');
		Assert.areEqual('/resource/123/', call.path, 'Path should be correct');
		Assert.isTrue(call.encodedQuery.contains('_HttpMethod=PATCH'), 'Should contain PATCH parameter');
		Assert.areEqual('{"update":"data"}', call.body, 'Body should be set');
	}
}
