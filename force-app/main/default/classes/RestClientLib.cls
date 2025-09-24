/**
 * @description This class is a wrapper around the RestLib class that is intended to be extended by developers
 * to provide a quick, safe, and reliable way of making REST callouts. By extending this class you're locking your
 * class to a specific Named Credential, which is a best practice for making callouts, and you're inheriting methods
 * like `get`, `post`, `put`, `patch`, and `del` that make it easy to make callouts without having to worry about
 * setting headers, or other common tasks.
 */
public with sharing virtual class RestClientLib extends RestClient {
	/**
	 * @description default constructor requiring a named credential string
	 *
	 * @param namedCredentialName String named credential name
	 */
	public RestClientLib(String namedCredentialName) {
		super(namedCredentialName);
	}

	/**
	 * @description  Makes an HTTP Callout to an api resource.
	 * Convenience method that assumes the Default Headers.
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   Body to send with this call.
	 * @return      `HttpResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse makeApiCall(
		HttpVerb method,
		String path,
		String query,
		String body
	) {
		return this.makeApiCall(new RestLibApiCall(method, path, query, body));
	}

	/**
	 * @description  Makes an HTTP Callout to an api resource with logging context.
	 * Convenience method that assumes the Default Headers.
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   Body to send with this call.
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return      `HttpResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse makeApiCall(
		HttpVerb method,
		String path,
		String query,
		String body,
		SObject relatedRecord
	) {
		return this.makeApiCall(new RestLibApiCall(method, path, query, body), relatedRecord);
	}

	/**
	 * @description  convenience version of makeApiCall without body param.
	 * Invokes omnibus version above, with blank body param and default headers.
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @return      `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse makeApiCall(
		HttpVerb method,
		String path,
		String query
	) {
		return this.makeApiCall(new RestLibApiCall(method, path, query, ''));
	}

	/**
	 * @description  convenience version of makeApiCall without body param with logging context.
	 * Invokes omnibus version above, with blank body param and default headers.
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return      `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse makeApiCall(
		HttpVerb method,
		String path,
		String query,
		SObject relatedRecord
	) {
		return this.makeApiCall(new RestLibApiCall(method, path, query, ''), relatedRecord);
	}

	/**
	 * @description  convenience version of makeApiCall without body or query
	 * params.
	 * Invokes omnibus version above, with blank body and query params
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @return      `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse makeApiCall(HttpVerb method, String path) {
		return this.makeApiCall(new RestLibApiCall(method, path, '', ''));
	}

	/**
	 * @description  convenience version of makeApiCall without body or query
	 * params with logging context.
	 * Invokes omnibus version above, with blank body and query params
	 * @param method HTTPVerb to use. See the enum above.
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return      `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse makeApiCall(HttpVerb method, String path, SObject relatedRecord) {
		return this.makeApiCall(new RestLibApiCall(method, path, '', ''), relatedRecord);
	}

	/**
	 * @description convenience method for a GET Call that only requires a path
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse get(String path) {
		return this.makeApiCall(HttpVerb.GET, path);
	}

	/**
	 * @description convenience method for a GET Call that only requires a path with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse get(String path, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.GET, path, relatedRecord);
	}

	/**
	 * @description convenience method for a GET Call that only requires a path
	 * and query
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse get(String path, String query) {
		return this.makeApiCall(HttpVerb.GET, path, query);
	}

	/**
	 * @description convenience method for a GET Call that only requires a path
	 * and query with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse get(String path, String query, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.GET, path, query, relatedRecord);
	}

	/**
	 * @description convenience method for deleting a resource based only on
	 * path
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse del(String path) {
		return this.makeApiCall(HttpVerb.DEL, path);
	}

	/**
	 * @description convenience method for deleting a resource based only on
	 * path with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse del(String path, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.DEL, path, relatedRecord);
	}

	/**
	 * @description convenience method for a Delete Call that only requires a
	 * path and query
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse del(String path, String query) {
		return this.makeApiCall(HttpVerb.DEL, path, query);
	}

	/**
	 * @description convenience method for a Delete Call that only requires a
	 * path and query with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse del(String path, String query, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.DEL, path, query, relatedRecord);
	}

	/**
	 * @description convenience method for a POST Call that only requires a path
	 * and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse post(String path, String body) {
		return this.makeApiCall(HttpVerb.POST, path, '', body);
	}

	/**
	 * @description convenience method for a POST Call that only requires a path
	 * and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse post(String path, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.POST, path, '', body, relatedRecord);
	}

	/**
	 * @description convenience method for a POST Call that only requires a
	 * path, query and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse post(String path, String query, String body) {
		return this.makeApiCall(HttpVerb.POST, path, query, body);
	}

	/**
	 * @description convenience method for a POST Call that only requires a
	 * path, query and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse post(String path, String query, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.POST, path, query, body, relatedRecord);
	}

	/**
	 * @description convenience method for a PUT Call that only requires a path
	 * and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse put(String path, String body) {
		return this.makeApiCall(HttpVerb.PUT, path, '', body);
	}

	/**
	 * @description convenience method for a PUT Call that only requires a path
	 * and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse put(String path, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.PUT, path, '', body, relatedRecord);
	}

	/**
	 * @description convenience method for a PUT Call that only requires a path,
	 * query and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse put(String path, String query, String body) {
		return this.makeApiCall(HttpVerb.PUT, path, query, body);
	}

	/**
	 * @description convenience method for a PUT Call that only requires a path,
	 * query and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse put(String path, String query, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.PUT, path, query, body, relatedRecord);
	}

	/**
	 * @description convenience method for a PATCH Call that only requires a
	 * path and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse patch(String path, String body) {
		return this.makeApiCall(HttpVerb.PATCH, path, '', body);
	}

	/**
	 * @description convenience method for a PATCH Call that only requires a
	 * path and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse patch(String path, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.PATCH, path, '', body, relatedRecord);
	}

	/**
	 * @description convenience method for a PATCH Call that only requires a
	 * path, query and body
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	protected HttpResponse patch(String path, String query, String body) {
		return this.makeApiCall(HttpVerb.PATCH, path, query, body);
	}

	/**
	 * @description convenience method for a PATCH Call that only requires a
	 * path, query and body with logging context
	 * @param path   Http path component of the URL. ie: `/path/to/resource`
	 * @param query  Query component of the URL ie: after `?foo=bar`
	 * @param body   JSON string to post
	 * @param relatedRecord The SObject record to associate with the API call for logging purposes
	 * @return     `HTTPResponse`
	 */
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	protected HttpResponse patch(String path, String query, String body, SObject relatedRecord) {
		return this.makeApiCall(HttpVerb.PATCH, path, query, body, relatedRecord);
	}
}
