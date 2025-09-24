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

	@isTest
	private static void testRestLibApiCallWithMethodPatch() {
		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create()
			.withMethod(HttpVerb.PATCH)
			.withPath('/test')
			.withQuery('existing=param');
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, call.method, 'PATCH should be converted to POST');
		Assert.areEqual('/test/', call.path, 'Path should be correct');
		Assert.isTrue(call.encodedQuery.contains('_HttpMethod=PATCH'), 'Should contain PATCH parameter');
		Assert.isTrue(call.encodedQuery.contains('existing=param'), 'Should preserve existing query params');
	}

	@isTest
	private static void testRestLibApiCallWithMethodPatchNoExistingQuery() {
		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create()
			.withMethod(HttpVerb.PATCH)
			.withPath('/test');
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, call.method, 'PATCH should be converted to POST');
		Assert.areEqual('/test/', call.path, 'Path should be correct');
		Assert.areEqual('?_HttpMethod=PATCH', call.encodedQuery, 'Should have only PATCH parameter');
	}

	@isTest
	private static void testRestLibApiCallTimeoutProperty() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create();
		RestLibApiCall call2 = RestLibApiCall.create().withTimeout(30000);
		Test.stopTest();

		Assert.areEqual(RestLibApiCall.DEFAULT_TIMEOUT, call1.timeout, 'Should use default timeout');
		Assert.areEqual(30000, call2.timeout, 'Should use custom timeout');
	}

	@isTest
	private static void testRestLibApiCallPathPropertyEdgeCases() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create().withPath('');
		RestLibApiCall call2 = RestLibApiCall.create().withPath(null);
		RestLibApiCall call3 = RestLibApiCall.create().withPath('noSlash');
		RestLibApiCall call4 = RestLibApiCall.create().withPath('/withSlash');
		Test.stopTest();

		Assert.areEqual('/', call1.path, 'Empty path should default to /');
		Assert.areEqual('/', call2.path, 'Null path should default to /');
		Assert.areEqual('/noSlash/', call3.path, 'Path without slash should get leading and trailing slashes');
		Assert.areEqual('/withSlash/', call4.path, 'Path with leading slash should get trailing slash');
	}

	@isTest
	private static void testRestLibApiCallQueryPropertyEdgeCases() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create().withQuery('');
		RestLibApiCall call2 = RestLibApiCall.create().withQuery(null);
		RestLibApiCall call3 = RestLibApiCall.create().withQuery('param=value');
		RestLibApiCall call4 = RestLibApiCall.create().withQuery('?prefixed');
		Test.stopTest();

		Assert.areEqual(null, call1.encodedQuery, 'Empty query should return null for encodedQuery');
		Assert.areEqual(null, call2.encodedQuery, 'Null query should return null for encodedQuery');
		Assert.areEqual('?param%3Dvalue', call3.encodedQuery, 'Query should be URL encoded');
		Assert.areEqual('?prefixed', call4.encodedQuery, 'Pre-prefixed query should remain unchanged');
	}

	@isTest
	private static void testRestLibApiCallHeadersProperty() {
		Test.startTest();
		RestLibApiCall call1 = RestLibApiCall.create();
		RestLibApiCall call2 = RestLibApiCall.create().withHeaders(new Map<String, String>{'Custom' => 'Value'});
		Test.stopTest();

		Assert.areEqual('application/json', call1.functionalHeaders.get('Content-Type'), 'Should use default headers');
		Assert.areEqual('application/json', call1.functionalHeaders.get('Accept'), 'Should use default headers');
		Assert.areEqual('Value', call2.functionalHeaders.get('Custom'), 'Should use custom headers');
		Assert.areEqual('application/json', call2.functionalHeaders.get('Content-Type'), 'Should not have default headers when custom provided');
	}

	@isTest
	private static void testRestLibApiCallHasBodyPropertyEdgeCases() {
		Test.startTest();
		RestLibApiCall getWithBody = RestLibApiCall.create()
			.usingGet()
			.withBody('{"test":"data"}');
		RestLibApiCall postWithoutBody = RestLibApiCall.create()
			.usingPost();
		RestLibApiCall putWithEmptyBody = RestLibApiCall.create()
			.usingPut()
			.withBody('');
		RestLibApiCall patchWithBody = RestLibApiCall.create()
			.usingPatch()
			.withBody('{"test":"data"}');
		Test.stopTest();

		Assert.isFalse(getWithBody.hasBody, 'GET with body should have hasBody=false');
		Assert.isFalse(postWithoutBody.hasBody, 'POST without body should have hasBody=false');
		Assert.isFalse(putWithEmptyBody.hasBody, 'PUT with empty body should have hasBody=false');
		Assert.isTrue(patchWithBody.hasBody, 'PATCH with body should have hasBody=true (converted to POST)');
	}

	@isTest
	private static void testRestLibApiCallMethodStringPropertyAllMethods() {
		Test.startTest();
		RestLibApiCall getCall = RestLibApiCall.create().usingGet();
		RestLibApiCall postCall = RestLibApiCall.create().usingPost();
		RestLibApiCall putCall = RestLibApiCall.create().usingPut();
		RestLibApiCall patchCall = RestLibApiCall.create().usingPatch();
		RestLibApiCall delCall = RestLibApiCall.create().usingDelete();
		RestLibApiCall headCall = RestLibApiCall.create().usingHead();
		Test.stopTest();

		Assert.areEqual('GET', getCall.methodString, 'GET method string should be GET');
		Assert.areEqual('POST', postCall.methodString, 'POST method string should be POST');
		Assert.areEqual('PUT', putCall.methodString, 'PUT method string should be PUT');
		Assert.areEqual('POST', patchCall.methodString, 'PATCH method string should be POST (converted)');
		Assert.areEqual('DELETE', delCall.methodString, 'DEL method string should be DELETE');
		Assert.areEqual('HEAD', headCall.methodString, 'HEAD method string should be HEAD');
	}

	@isTest
	private static void testRestLibApiCallWithHeaderChaining() {
		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create()
			.usingPost()
			.withPath('/api')
			.withHeader('Authorization', 'Bearer token123')
			.withHeader('X-Custom', 'Value1')
			.withHeader('X-Another', 'Value2');
		Test.stopTest();

		Assert.areEqual('Bearer token123', call.functionalHeaders.get('Authorization'), 'First header should be set');
		Assert.areEqual('Value1', call.functionalHeaders.get('X-Custom'), 'Second header should be set');
		Assert.areEqual('Value2', call.functionalHeaders.get('X-Another'), 'Third header should be set');
		Assert.areEqual(3, call.functionalHeaders.size(), 'Should have 3 custom headers');
	}

	@isTest
	private static void testRestLibApiCallWithHeadersOverwrite() {
		Map<String, String> initialHeaders = new Map<String, String>{
			'Content-Type' => 'application/xml',
			'Accept' => 'application/xml'
		};
		Map<String, String> newHeaders = new Map<String, String>{
			'Authorization' => 'Bearer token',
			'X-API-Key' => 'key123'
		};

		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create()
			.usingPost()
			.withHeaders(initialHeaders)
			.withHeaders(newHeaders);
		Test.stopTest();

		Assert.areEqual('Bearer token', call.functionalHeaders.get('Authorization'), 'New headers should be set');
		Assert.areEqual('key123', call.functionalHeaders.get('X-API-Key'), 'New headers should be set');
		Assert.areEqual(null, call.functionalHeaders.get('Content-Type'), 'Old headers should be overwritten');
		Assert.areEqual(null, call.functionalHeaders.get('Accept'), 'Old headers should be overwritten');
	}

	@isTest
	private static void testRestLibApiCallConstructorWithNullHeaders() {
		Test.startTest();
		RestLibApiCall call = new RestLibApiCall(
			HttpVerb.GET,
			'/test',
			'param=value',
			'{"data":"test"}',
			null
		);
		Test.stopTest();

		Assert.areEqual(HttpVerb.GET, call.method, 'Method should be GET');
		Assert.areEqual('/test/', call.path, 'Path should be correct');
		Assert.areEqual('param=value', call.query, 'Query should be set');
		Assert.areEqual('{"data":"test"}', call.body, 'Body should be set');
		Assert.areEqual('application/json', call.functionalHeaders.get('Content-Type'), 'Should use default headers when null provided');
	}

	@isTest
	private static void testRestLibApiCallFluentInterfaceComplexScenario() {
		Map<String, String> customHeaders = new Map<String, String>{
			'Authorization' => 'Bearer token123',
			'X-Request-ID' => 'req-456'
		};

		Test.startTest();
		RestLibApiCall call = RestLibApiCall.create()
			.usingPost()
			.withPath('/api/v1/users')
			.withQuery('include=profile,settings')
			.withBody('{"name":"John Doe","email":"john@example.com"}')
			.withHeaders(customHeaders)
			.withHeader('X-Custom', 'AdditionalValue')
			.withTimeout(45000);
		Test.stopTest();

		Assert.areEqual(HttpVerb.POST, call.method, 'Method should be POST');
		Assert.areEqual('/api/v1/users/', call.path, 'Path should be correct');
		Assert.areEqual('include=profile,settings', call.query, 'Query should be set');
		Assert.areEqual('{"name":"John Doe","email":"john@example.com"}', call.body, 'Body should be set');
		Assert.areEqual(45000, call.timeout, 'Timeout should be set');
		Assert.areEqual('Bearer token123', call.functionalHeaders.get('Authorization'), 'Authorization header should be set');
		Assert.areEqual('req-456', call.functionalHeaders.get('X-Request-ID'), 'Request ID header should be set');
		Assert.areEqual('AdditionalValue', call.functionalHeaders.get('X-Custom'), 'Custom header should be set');
		Assert.isTrue(call.hasBody, 'Should have body for POST with body');
	}

	@isTest
	private static void testRestClientLibConvenienceMethodsWithLogging() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);
		Account a = makeAccount();

		Test.startTest();
		// Test all convenience methods with logging context
		HttpResponse getRes = rc.get('/', a);
		HttpResponse getWithQueryRes = rc.get('/', 'param=value', a);
		HttpResponse delRes = rc.del('/', a);
		HttpResponse delWithQueryRes = rc.del('/', 'param=value', a);
		HttpResponse postRes = rc.post('/', '{"test":"data"}', a);
		HttpResponse postWithQueryRes = rc.post('/', 'param=value', '{"test":"data"}', a);
		HttpResponse putRes = rc.put('/', '{"test":"data"}', a);
		HttpResponse putWithQueryRes = rc.put('/', 'param=value', '{"test":"data"}', a);
		HttpResponse patchRes = rc.patch('/', '{"test":"data"}', a);
		HttpResponse patchWithQueryRes = rc.patch('/', 'param=value', '{"test":"data"}', a);
		Test.stopTest();

		// All should return 200 OK
		Assert.areEqual(200, getRes.getStatusCode(), 'GET with logging should work');
		Assert.areEqual(200, getWithQueryRes.getStatusCode(), 'GET with query and logging should work');
		Assert.areEqual(200, delRes.getStatusCode(), 'DELETE with logging should work');
		Assert.areEqual(200, delWithQueryRes.getStatusCode(), 'DELETE with query and logging should work');
		Assert.areEqual(200, postRes.getStatusCode(), 'POST with logging should work');
		Assert.areEqual(200, postWithQueryRes.getStatusCode(), 'POST with query and logging should work');
		Assert.areEqual(200, putRes.getStatusCode(), 'PUT with logging should work');
		Assert.areEqual(200, putWithQueryRes.getStatusCode(), 'PUT with query and logging should work');
		Assert.areEqual(200, patchRes.getStatusCode(), 'PATCH with logging should work');
		Assert.areEqual(200, patchWithQueryRes.getStatusCode(), 'PATCH with query and logging should work');
	}

	@isTest
	private static void testRestClientLibConvenienceMethodsWithoutLogging() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);

		Test.startTest();
		// Test all convenience methods without logging context
		HttpResponse getRes = rc.get('/');
		HttpResponse getWithQueryRes = rc.get('/', 'param=value');
		HttpResponse delRes = rc.del('/');
		HttpResponse delWithQueryRes = rc.del('/', 'param=value');
		HttpResponse postRes = rc.post('/', '{"test":"data"}');
		HttpResponse postWithQueryRes = rc.post('/', 'param=value', '{"test":"data"}');
		HttpResponse putRes = rc.put('/', '{"test":"data"}');
		HttpResponse putWithQueryRes = rc.put('/', 'param=value', '{"test":"data"}');
		HttpResponse patchRes = rc.patch('/', '{"test":"data"}');
		HttpResponse patchWithQueryRes = rc.patch('/', 'param=value', '{"test":"data"}');
		Test.stopTest();

		// All should return 200 OK
		Assert.areEqual(200, getRes.getStatusCode(), 'GET without logging should work');
		Assert.areEqual(200, getWithQueryRes.getStatusCode(), 'GET with query without logging should work');
		Assert.areEqual(200, delRes.getStatusCode(), 'DELETE without logging should work');
		Assert.areEqual(200, delWithQueryRes.getStatusCode(), 'DELETE with query without logging should work');
		Assert.areEqual(200, postRes.getStatusCode(), 'POST without logging should work');
		Assert.areEqual(200, postWithQueryRes.getStatusCode(), 'POST with query without logging should work');
		Assert.areEqual(200, putRes.getStatusCode(), 'PUT without logging should work');
		Assert.areEqual(200, putWithQueryRes.getStatusCode(), 'PUT with query without logging should work');
		Assert.areEqual(200, patchRes.getStatusCode(), 'PATCH without logging should work');
		Assert.areEqual(200, patchWithQueryRes.getStatusCode(), 'PATCH with query without logging should work');
	}

	@isTest
	private static void testRestClientLibMakeApiCallOverloads() {
		RestClientLib rc = new RestClientLib('DummyNamedCredential');
		HttpCalloutMockFactory mock = new HttpCalloutMockFactory(
			200,
			'OK',
			'OK',
			new Map<String, String>()
		);
		Test.setMock(HttpCalloutMock.class, mock);
		Account a = makeAccount();

		Test.startTest();
		// Test all makeApiCall overloads
		HttpResponse res1 = rc.makeApiCall(HttpVerb.GET, '/test');
		HttpResponse res2 = rc.makeApiCall(HttpVerb.GET, '/test', a);
		HttpResponse res3 = rc.makeApiCall(HttpVerb.GET, '/test', 'param=value');
		HttpResponse res4 = rc.makeApiCall(HttpVerb.GET, '/test', 'param=value', a);
		HttpResponse res5 = rc.makeApiCall(HttpVerb.POST, '/test', 'param=value', '{"data":"test"}');
		HttpResponse res6 = rc.makeApiCall(HttpVerb.POST, '/test', 'param=value', '{"data":"test"}', a);
		Test.stopTest();

		// All should return 200 OK
		Assert.areEqual(200, res1.getStatusCode(), 'makeApiCall with method and path should work');
		Assert.areEqual(200, res2.getStatusCode(), 'makeApiCall with method, path, and record should work');
		Assert.areEqual(200, res3.getStatusCode(), 'makeApiCall with method, path, and query should work');
		Assert.areEqual(200, res4.getStatusCode(), 'makeApiCall with method, path, query, and record should work');
		Assert.areEqual(200, res5.getStatusCode(), 'makeApiCall with method, path, query, and body should work');
		Assert.areEqual(200, res6.getStatusCode(), 'makeApiCall with method, path, query, body, and record should work');
	}

	@isTest
	private static void testRestClientLibConstructor() {
		Test.startTest();
		RestClientLib rc = new RestClientLib('TestNamedCredential');
		Test.stopTest();

		Assert.areNotEqual(null, rc, 'RestClientLib should be created');
		Assert.areEqual('TestNamedCredential', rc.namedCredentialName, 'Named credential should be set');
	}

	@isTest
	private static void testRestLibApiCallEnsureStringEndsInSlashEdgeCases() {
		Test.startTest();
		String result1 = RestLibApiCall.ensureStringEndsInSlash('');
		String result2 = RestLibApiCall.ensureStringEndsInSlash(null);
		String result3 = RestLibApiCall.ensureStringEndsInSlash('noSlash');
		String result4 = RestLibApiCall.ensureStringEndsInSlash('/withSlash');
		String result5 = RestLibApiCall.ensureStringEndsInSlash('multiple/slashes/');
		Test.stopTest();

		Assert.areEqual('/', result1, 'Empty string should return /');
		Assert.areEqual('/', result2, 'Null string should return /');
		Assert.areEqual('noSlash/', result3, 'String without slash should get trailing slash');
		Assert.areEqual('/withSlash/', result4, 'String with leading slash should get trailing slash');
		Assert.areEqual('multiple/slashes/', result5, 'String already ending with slash should remain unchanged');
	}
}
