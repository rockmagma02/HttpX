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

import Dispatch
import Foundation

/// Synchronous HTTP client.
@available(macOS 10.15, *)
public class SyncClient: BaseClient {
    // MARK: Lifecycle

    /// Initializes a new instance of `SyncClient`.
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
    ///   - timeout: The timeout interval for the request. Defaults to `kDefaultTimeout`, i.e., 5 seconds.
    ///   - followRedirects: A Boolean value indicating whether the client should
    ///        follow HTTP redirects. Defaults to `false`.
    ///   - maxRedirects: The maximum number of redirects to follow. Defaults to `kDefaultMaxRedirects`, i.e., 20.
    ///   - eventHooks: Hooks allowing for observing and mutating request and response.
    ///        Defaults to an empty `EventHooks` instance.
    ///   - baseURL: The base URL for the network requests. Defaults to `nil`.
    ///        Every Requests' URL will be merged with this URL before sending.
    ///   - defaultEncoding: The default string encoding for the request. Defaults to `.utf8`.
    override public init(
        auth: AuthType? = nil,
        params: QueryParamsType? = nil,
        headers: HeadersType? = nil,
        cookies: CookiesType? = nil,
        cookieIdentifier: String? = nil,
        timeout: TimeInterval = kDefaultTimeout,
        followRedirects: Bool = false,
        maxRedirects: Int = kDefaultMaxRedirects,
        eventHooks: EventHooks = EventHooks(),
        baseURL: URLType? = nil,
        defaultEncoding: String.Encoding = .utf8
    ) {
        super.init(
            auth: auth,
            params: params,
            headers: headers,
            cookies: cookies,
            cookieIdentifier: cookieIdentifier,
            timeout: timeout,
            followRedirects: followRedirects,
            maxRedirects: maxRedirects,
            eventHooks: eventHooks,
            baseURL: baseURL,
            defaultEncoding: defaultEncoding
        )
        delegate = SyncStreamDelegate()
        session = URLSession(configuration: session.configuration, delegate: delegate, delegateQueue: nil)
    }

    deinit {}

    // MARK: Public

    /// Sends a network request synchronously.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use for the request.
    ///     - url: The URL to which the request should be sent, should be merged with the `baseURL`.
    ///     - content: The content to send with the request. Defaults to `nil`.
    ///     - params: The query parameters to append to the URL. Defaults to `nil`, should be merged with the `params`.
    ///     - headers: The HTTP headers to send with the request. Defaults to `nil`,
    ///             should be merged with the `headers`.
    ///      - timeout: The timeout interval for the request. Defaults to `nil`, should be merged with the `timeout`.
    ///     - auth: The authentication strategy to use for the request. Defaults to `nil`, should override the `auth`.
    ///     - followRedirects: A Boolean value indicating whether the client should follow
    ///             HTTP redirects. Defaults to `nil`, should override the `followRedirects`.
    ///
    /// - Returns: A `Response` instance containing the response to the request.
    ///
    /// - Throws: An error if the request fails.
    public func request(
        method: HTTPMethod,
        url: URLType,
        content: Content? = nil,
        params: QueryParamsType? = nil,
        headers: HeadersType? = nil,
        timeout: TimeInterval? = nil,
        auth: AuthType? = nil,
        followRedirects: Bool? = nil // swiftlint:disable:this discouraged_optional_boolean
    ) throws -> Response {
        let request = try buildRequest(
            method: method,
            url: url,
            content: content,
            params: params,
            headers: headers,
            timeout: timeout
        )
        return try sendRequest(request: request, auth: auth, followRedirects: followRedirects)
    }

    /// Sends a network request synchronously and return in with stream.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use for the request.
    ///     - url: The URL to which the request should be sent, should be merged with the `baseURL`.
    ///     - content: The content to send with the request. Defaults to `nil`.
    ///     - params: The query parameters to append to the URL. Defaults to `nil`, should be merged with the `params`.
    ///     - headers: The HTTP headers to send with the request. Defaults to `nil`,
    ///         should be merged with the `headers`.
    ///      - timeout: The timeout interval for the request. Defaults to `nil`, should be merged with the `timeout`.
    ///     - auth: The authentication strategy to use for the request. Defaults to `nil`, should override the `auth`.
    ///     - followRedirects: A Boolean value indicating whether the client should follow
    ///         HTTP redirects. Defaults to `nil`, should override the `followRedirects`.
    ///      - chunkSize: The size of the chunks to read from the stream. Defaults to
    ///         `kDefaultChunkSize`, i.e. 1024 bytes.
    ///
    /// - Returns: A `Response` instance containing the response to the request.
    ///
    /// - Throws: An error if the request fails.
    public func stream(
        method: HTTPMethod,
        url: URLType,
        content: Content? = nil,
        params: QueryParamsType? = nil,
        headers: HeadersType? = nil,
        timeout: TimeInterval? = nil,
        auth: AuthType? = nil,
        followRedirects: Bool? = nil, // swiftlint:disable:this discouraged_optional_boolean
        chunkSize: Int = kDefaultChunkSize
    ) throws -> Response {
        let request = try buildRequest(
            method: method,
            url: url,
            content: content,
            params: params,
            headers: headers,
            timeout: timeout
        )
        return try sendRequest(
            request: request,
            stream: (true, chunkSize),
            auth: auth,
            followRedirects: followRedirects
        )
    }

    /// Sends a network request with the given parameters, handling authentication and redirects as specified.
    ///
    /// This method sends a network request based on the provided `URLRequest` object. It supports streaming
    /// of the response if required. Authentication and redirect following can be customized via the method parameters.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be sent.
    ///   - stream: A tuple indicating whether the response should be streamed (`true`)
    ///             and the chunk size for streaming. The default is `(false, nil)`, indicating no streaming.
    ///   - auth: An optional `AuthType` to be used for the request. If `nil`,
    ///             the client's default authentication will be used.
    ///   - followRedirects: An optional Boolean indicating whether redirects should be followed. If `nil`, the client's
    ///                      default setting will be used.
    ///
    /// - Returns: A `Response` object containing the response data.
    ///
    /// - Throws: An error if the request fails, including network errors or authentication failures.
    public func sendRequest(
        request: URLRequest,
        stream: (Bool, Int?) = (false, nil),
        auth: AuthType? = nil,
        followRedirects: Bool? = nil // swiftlint:disable:this discouraged_optional_boolean
    ) throws -> Response {
        let followRedirects = followRedirects ?? self.followRedirects
        let auth = auth?.buildAuth() ?? self.auth

        return try sendHandlingAuth(
            request: request,
            auth: auth,
            followRedirects: followRedirects,
            stream: stream,
            history: []
        )
    }

    // MARK: Internal

    internal var delegate: SyncStreamDelegate? // swiftlint:disable:this weak_delegate

    internal func sendHandlingAuth(
        request: URLRequest,
        auth: BaseAuth,
        followRedirects: Bool,
        stream: (Bool, Int?) = (false, nil),
        history: [Response] = []
    ) throws -> Response {
        var history = history
        var (request, authStop) = try auth.syncAuthFlow(request: request, lastResponse: nil)

        guard request != nil else {
            throw HttpXError.invalidRequest(message: "Auth flow did not return a request")
        }

        var response = try sandHandlingRedirect(
            request: request!,
            followRedirects: followRedirects,
            stream: stream,
            history: history
        )

        while !authStop {
            (request, authStop) = try auth.syncAuthFlow(request: request, lastResponse: response)
            if let request {
                response = try sandHandlingRedirect(
                    request: request,
                    followRedirects: followRedirects,
                    stream: stream,
                    history: history
                )
                response.history = history
                history += [response]
            } else {
                break
            }
        }

        return response
    }

    internal func sandHandlingRedirect(
        request: URLRequest,
        followRedirects: Bool,
        stream: (Bool, Int?) = (false, nil),
        history: [Response] = []
    ) throws -> Response {
        var request = request
        var history = history
        var response = Response()
        while true {
            if history.count >= maxRedirects {
                throw HttpXError.redirectError(message: "Exceeded maximum number of redirects")
            }

            eventHooks.request.forEach { $0(&request) }
            response = try sendSingleRequest(request: request, stream: stream)
            eventHooks.response.forEach { $0(&response) }
            response.history = history

            if let res = response.URLResponse {
                guard res.hasRedirectLocation else {
                    break
                }
            }

            if followRedirects {
                response.readAllFormSyncStream()
            }

            request = try buildRedirectRequest(request: request, response: response)
            history += [response]

            if !followRedirects {
                response.nextRequest = request
                break
            }
        }
        return response
    }

    internal func sendSingleRequest(
        request: URLRequest,
        stream: (Bool, Int?) = (false, kDefaultChunkSize)
    ) throws -> Response {
        func getResponse(request: URLRequest) -> Response {
            let signal = DispatchSemaphore(value: 0)
            let response = Response()
            let task = session.dataTask(with: request) { data, res, error in
                response.data = data
                response.URLResponse = res
                response.error = error
                signal.signal()
            }
            task.resume()
            // make the addition response can be collect automatically by Garbage Collection
            delegate?.removeResponse(forTaskIdentifier: task.taskIdentifier)
            signal.wait()
            return response
        }

        func getStream(request: URLRequest, chunkSize: Int = kDefaultChunkSize) -> Response {
            delegate?.chunkSize = chunkSize
            let task = session.dataTask(with: request)
            task.resume()
            let response = delegate?.getResponse(forTaskIdentifier: task.taskIdentifier)
            return response!
        }

        var response: Response

        if let mockResponse = Mock.getResponse(request: request, mode: .sync, stream: stream.0, chunkSize: stream.1) {
            response = mockResponse
        } else {
            if stream.0 {
                let chunkSize = stream.1 ?? kDefaultChunkSize
                response = getStream(request: request, chunkSize: chunkSize)
            } else {
                response = getResponse(request: request)
            }

            if let error = response.error {
                response.error = buildError(error)
            }
        }

        if let error = response.error, response.URLResponse == nil {
            throw error
        }
        return response
    }
}
