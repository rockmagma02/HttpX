// Copyright 2024-2024 Ruiyang Sun. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// MARK: - BaseClient

/// The `BaseClient` class is the base class for making HTTP requests.
public class BaseClient {
    // MARK: Lifecycle

    /// Initializes a new instance of `SyncClient` or `AsyncClient`.
    ///
    /// - Parameters:
    ///   - auth: The authentication strategy to use for network requests.
    ///         Should pass a `AuthType` object. Defaults to `nil`, when Default,
    ///         request will use the auth request set or not to use auth.
    ///   - params: The query parameters to append to every request. Defaults to `nil`.
    ///         The params which request set will append or override this params.
    ///   - headers: The HTTP headers to send with every request. Defaults to `nil`.
    ///         The headers which request set will append or override this headers.
    ///   - cookies: The cookies will set when `URLSession` instance created, and then
    ///         be managed by the `URLSession` instance. Defaults to `nil`.
    ///   - cookieIdentifier: The identifier for the cookies. Defaults to `nil`,
    ///         when is nil, will use a random UUID string.
    ///   - timeout: The timeout interval for the request.
    ///   - followRedirects: A Boolean value indicating whether the client should
    ///        follow HTTP redirects. Defaults to `false`.
    ///   - maxRedirects: The maximum number of redirects to follow. Defaults to `kDefaultMaxRedirects`, i.e., 20.
    ///   - eventHooks: Hooks allowing for observing and mutating request and response.
    ///        Defaults to an empty `EventHooks` instance.
    ///   - baseURL: The base URL for the network requests. Defaults to `nil`.
    ///         Every Requests' URL will be merged with this URL before sending.
    ///   - defaultEncoding: The default string encoding for the request. Defaults to `.utf8`.
    ///   - configuration: The configuration for the `URLSession`. Defaults to `.default`.
    public init(
        auth: AuthType? = nil,
        params: QueryParamsType? = nil,
        headers: HeadersType? = nil,
        cookies: CookiesType? = nil,
        cookieIdentifier: String? = nil,
        timeout: Timeout = .init(),
        followRedirects: Bool = false,
        maxRedirects: Int = kDefaultMaxRedirects,
        eventHooks: EventHooks = EventHooks(),
        baseURL: URLType? = nil,
        defaultEncoding: String.Encoding = .utf8,
        configuration: URLSessionConfiguration = .default
    ) {
        baseURLPrivate = baseURL?.buildURL()
        authPrivate = auth?.buildAuth() ?? EmptyAuth()
        paramsPrivate = params?.buildQueryItems() ?? []
        headersPrivate = headers?.buildHeaders() ?? []
        timeoutPrivate = timeout
        maxRedirectsPrivate = maxRedirects
        followRedirectsPrivate = followRedirects
        eventHooksPrivate = eventHooks
        defaultEncodingPrivate = defaultEncoding
        configurationPrivate = configuration

        self.cookieIdentifier = cookieIdentifier ?? "HttpX.Client.\(UUID().uuidString)"
        let cookieStorage = HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: self.cookieIdentifier)
        for cookie in cookies?.buildCookies() ?? [] {
            cookieStorage.setCookie(cookie)
        }

        let delegate = HttpXDelegate()
        configuration.httpCookieStorage = cookieStorage
        configuration.timeoutIntervalForRequest = timeoutPrivate.request
        configuration.timeoutIntervalForResource = timeoutPrivate.resource
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    deinit {}

    // MARK: Public

    /// Returns the timeout interval for the request.
    public var timeout: Timeout {
        timeoutPrivate.request = session.configuration.timeoutIntervalForRequest
        timeoutPrivate.resource = session.configuration.timeoutIntervalForResource
        return timeoutPrivate
    }

    /// Returns the event hooks allowing for observing and mutating request and response.
    public var eventHooks: EventHooks { eventHooksPrivate }

    /// Returns the authentication strategy used for network requests.
    public var auth: BaseAuth { authPrivate }

    /// Returns the base URL for the network requests.
    public var baseURL: URL? { baseURLPrivate }

    /// Returns the HTTP headers sent with every request.
    public var headers: [(String, String)] { headersPrivate }

    /// Returns the cookies sent with every request.
    public var cookies: [HTTPCookie] {
        let storage = session.configuration.httpCookieStorage
        return storage!.cookies!
    }

    /// Returns the query parameters appended to every request.
    public var params: [URLQueryItem] { paramsPrivate }

    /// Indicates whether the client should follow HTTP redirects.
    public var followRedirects: Bool { followRedirectsPrivate }
    /// Returns the maximum number of redirects to follow.
    public var maxRedirects: Int { maxRedirectsPrivate }

    /// Returns the default string encoding for the request.
    public var defaultEncoding: String.Encoding { defaultEncodingPrivate }

    /// Returns the configuration for the client.
    public var configuration: URLSessionConfiguration { configurationPrivate }

    /// Returns the cookies storage for the client.
    public var cookieStorage: HTTPCookieStorage? {
        session.configuration.httpCookieStorage
    }

    /// Sets the timeout interval for the request.
    public func setTimeout(_ timeout: Timeout) {
        timeoutPrivate = timeout
    }

    /// Sets the timeout interval for the request.
    public func setTimeout(connect: TimeInterval? = nil, request: TimeInterval? = nil, resource: TimeInterval? = nil) {
        let timeout = Timeout(
            connect: connect ?? timeout.connect,
            request: request ?? timeoutPrivate.request,
            resource: resource ?? timeoutPrivate.resource
        )
        setTimeout(timeout)
    }

    /// Sets the event hooks allowing for observing and mutating request and response.
    public func setEventHooks(_ eventHooks: EventHooks) {
        eventHooksPrivate = eventHooks
    }

    /// Sets the authentication strategy used for network requests.
    public func setAuth(_ auth: AuthType) {
        authPrivate = auth.buildAuth()
    }

    /// Sets the base URL for the network requests.
    public func setBaseURL(_ baseURL: URLType) {
        baseURLPrivate = baseURL.buildURL()
    }

    /// Sets the HTTP headers to be sent with every request.
    public func setHeaders(_ headers: HeadersType) {
        headersPrivate = headers.buildHeaders()
    }

    /// Sets the query parameters to be appended to every request.
    public func setParams(_ params: QueryParamsType) {
        paramsPrivate = params.buildQueryItems()
    }

    /// Sets the redirect behavior for the client.
    public func setRedirects(follow: Bool = false, max: Int = kDefaultMaxRedirects) {
        followRedirectsPrivate = follow
        maxRedirectsPrivate = max
    }

    /// Sets the default string encoding for the request.
    public func setDefaultEncoding(_ encoding: String.Encoding) {
        defaultEncodingPrivate = encoding
    }

    /// Builds a URLRequest with the specified parameters.
    ///
    /// This method constructs a URLRequest using the provided parameters. If a parameter is not provided,
    /// the default value from the `BaseClient` instance is used. The URL is constructed or merged based on
    /// the `baseURL` of the client and the provided `url` parameter. Headers and query parameters are merged
    /// with the default values. The body content is encoded using the specified or default encoding.
    ///
    /// - Parameters:
    ///   - method: The HTTP method for the request.
    ///   - url: The URL or URLType for the request. If nil, the `baseURL` of the client is used.
    ///   - content: The content to be sent with the request. If nil, no content is sent.
    ///   - params: The query parameters to be appended to the URL. If nil, default parameters are used.
    ///   - headers: The headers to be added to the request. If nil, default headers are used.
    /// - Returns: A configured URLRequest instance.
    /// - Throws: `HttpXError.invalidURL` if the URL is invalid or cannot be constructed.
    public func buildRequest(
        method: HTTPMethod,
        url: URLType? = nil,
        content: Content? = nil,
        params: QueryParamsType? = nil,
        headers: HeadersType? = nil
    ) throws -> URLRequest {
        let url = url == nil ? baseURL : try Self.mergeURL(url!, original: baseURL)
        guard var url else {
            throw HttpXError.invalidURL(message: "the request URL is invalid or conflicting with the base URL.")
        }

        let headers = headers == nil ? self.headers : Self.mergeHeaders(headers!, original: self.headers)
        let params = params == nil ? self.params : Self.mergeQueryParams(params!, original: self.params)

        try url.mergeQueryItems(params)
        var request = URLRequest(url: url, timeoutInterval: timeout.connect)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        try content?.encodeContent(request: &request, encode: defaultEncoding)
        return request
    }

    // MARK: Internal

    internal var session: URLSession

    internal static func mergeURL(_ new: URLType, original: URL?) throws -> URL {
        let newURL = new.buildURL()
        if let newURL {
            if newURL.isRelativeURL {
                return URL(string: newURL.absoluteString, relativeTo: original)!
            }
            return newURL
        }
        throw HttpXError.invalidURL(message: "the request URL is invalid or conflicting with the base URL.")
    }

    internal static func mergeHeaders(_ new: HeadersType, original: [(String, String)]) -> [(String, String)] {
        let newHeaders = new.buildHeaders()
        var mergedHeaders = original
        for (key, value) in newHeaders {
            if let index = original.firstIndex(where: { $0.0 == key }) {
                mergedHeaders[index] = (key, value)
            } else {
                mergedHeaders.append((key, value))
            }
        }
        return mergedHeaders
    }

    internal static func mergeQueryParams(_ new: QueryParamsType, original: [URLQueryItem]) -> [URLQueryItem] {
        let newQueryParams = new.buildQueryItems()
        var mergedQueryParams = original
        for queryParam in newQueryParams {
            if let index = original.firstIndex(where: { $0.name == queryParam.name }) {
                mergedQueryParams[index] = queryParam
            } else {
                mergedQueryParams.append(queryParam)
            }
        }
        return mergedQueryParams
    }

    internal func buildRedirectRequest(request: URLRequest, response: Response) throws -> URLRequest {
        let method = try redirectMethod(request: request, response: response)
        let url = try redirectURL(request: request, response: response)
        let headers = redirectHeaders(request: request, url: url, method: method)
        let content = redirectContent(request: request, method: method)

        var request = URLRequest(url: url, timeoutInterval: request.timeoutInterval)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = content
        return request
    }

    internal func redirectMethod(request: URLRequest, response: Response) throws -> HTTPMethod {
        let methodString = request.httpMethod!
        let statusCode = response.statusCode
        let seeOther = 303
        let found = 302
        let movedPermanently = 301

        var method = HTTPMethod(rawValue: methodString)!
        if statusCode == seeOther, method != .head { // See Other
            method = .get
        }
        if statusCode == found, method != .head { // Found
            method = .get
        }
        if statusCode == movedPermanently, method != .post, method != .head { // Moved Permanently
            method = .get
        }

        return method
    }

    internal func redirectURL(request: URLRequest, response: Response) throws -> URL {
        if let location = response.value(forHTTPHeaderField: "Location") {
            guard var newURL = URL(string: location) else {
                throw HttpXError.redirectError(message: "The Redirect URL is invalid.")
            }

            var newURLComponents = URLComponents(url: newURL, resolvingAgainstBaseURL: true)!
            if newURLComponents.scheme != nil, newURLComponents.host == nil {
                newURLComponents.host = request.url!.host
            }

            newURL = newURLComponents.url!
            if newURL.isRelativeURL {
                var oldURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
                oldURLComponents.path = "/"
                newURL = URL(string: newURL.absoluteString, relativeTo: oldURLComponents.url)!
                newURLComponents = URLComponents(url: newURL, resolvingAgainstBaseURL: true)!
            }

            if request.url!.fragment != nil, newURLComponents.fragment == nil {
                newURLComponents.fragment = request.url!.fragment
            }

            return newURLComponents.url!
        }
        throw HttpXError.invalidResponse(message: "The response has no Location header.")
    }

    internal func redirectHeaders(request: URLRequest, url: URL, method: HTTPMethod) -> [(String, String)] {
        var headers = request.allHTTPHeaderFields ?? [:]

        if !URL.sameOrigin(url, request.url!), !URL.isHttpsRedirect(request.url!, location: url) {
            headers.removeValue(forKey: "Authorization")
        }

        if method.rawValue != request.httpMethod!, method == .get {
            headers.removeValue(forKey: "Content-Length")
            headers.removeValue(forKey: "Transfer-Encoding")
        }

        return headers.map { ($0.key, $0.value) }
    }

    internal func redirectContent(request: URLRequest, method: HTTPMethod) -> Data? {
        if method.rawValue != request.httpMethod!, method == .get {
            return nil
        }

        if request.httpBody == nil, request.httpBodyStream != nil {
            return request.httpBodyStream!.readAllData()
        }

        return request.httpBody
    }

    // MARK: Private

    private var baseURLPrivate: URL?
    private var authPrivate: BaseAuth
    private var paramsPrivate: [URLQueryItem] = []
    private var headersPrivate: [(String, String)] = []
    private var followRedirectsPrivate: Bool
    private var maxRedirectsPrivate: Int
    private var eventHooksPrivate: EventHooks
    private var defaultEncodingPrivate: String.Encoding
    private var cookieIdentifier: String
    private var configurationPrivate: URLSessionConfiguration

    private var timeoutPrivate: Timeout {
        didSet {
            session.configuration.timeoutIntervalForRequest = timeoutPrivate.request
            session.configuration.timeoutIntervalForResource = timeoutPrivate.resource
        }
    }
}
