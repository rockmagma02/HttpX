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
import SyncStream

/// Synchronous HTTP client.
public class SyncClient: BaseClient {
    // MARK: Lifecycle

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
        followRedirects: Bool? = nil, // swiftlint:disable:this discouraged_optional_boolean
        chunkSize: Int? = nil
    ) throws -> Response {
        let request = try buildRequest(
            method: method,
            url: url,
            content: content,
            params: params,
            headers: headers,
            timeout: timeout
        )
        return try sendRequest(request: request, auth: auth, followRedirects: followRedirects, chunkSize: chunkSize)
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
        auth: AuthType? = nil,
        followRedirects: Bool? = nil, // swiftlint:disable:this discouraged_optional_boolean
        chunkSize: Int? = nil
    ) throws -> Response {
        let followRedirects = followRedirects ?? self.followRedirects
        let auth = auth?.buildAuth() ?? self.auth

        return try sendHandlingAuth(
            request: request,
            auth: auth,
            followRedirects: followRedirects,
            history: [],
            chunkSize: chunkSize
        )
    }

    // MARK: Internal

    internal func sendHandlingAuth(
        request: URLRequest,
        auth: BaseAuth,
        followRedirects: Bool,
        history: [Response] = [],
        chunkSize: Int? = nil
    ) throws -> Response {
        var request = request
        var history = history
        var response: Response?
        let authFlow = auth.authFlowAdapter(request)
        request = try authFlow.next()

        while true {
            response = try sandHandlingRedirect(
                request: request,
                followRedirects: followRedirects,
                history: history,
                chunkSize: chunkSize
            )

            let nextRequest: URLRequest
            do {
                nextRequest = try authFlow.send(response!)
            } catch {
                if error is StopIteration<NoneType> {
                    break
                }
                throw error
            }

            response?.historyInternal = history
            request = nextRequest
            history += [response!]
        }

        return response!
    }

    internal func sandHandlingRedirect(
        request: URLRequest,
        followRedirects: Bool,
        history: [Response] = [],
        chunkSize: Int? = nil
    ) throws -> Response {
        var request = request
        var history = history
        var response = Response(url: request.url!, error: HttpXError.invalidResponse())
        while true {
            if history.count >= maxRedirects {
                throw HttpXError.redirectError(message: "Exceeded maximum number of redirects")
            }

            eventHooks.request.forEach { $0(&request) }
            response = try sendSingleRequest(request: request, chunkSize: chunkSize)
            eventHooks.response.forEach { $0(&response) }
            response.historyInternal = history

            guard response.hasRedirectLocation else {
                break
            }

            if followRedirects {
                _ = response.getData()
            }

            request = try buildRedirectRequest(request: request, response: response)
            history += [response]

            if !followRedirects {
                response.nextRequestInternal = request
                break
            }
        }
        return response
    }

    internal func sendSingleRequest(
        request: URLRequest,
        chunkSize: Int? = nil
    ) throws -> Response {
        if let response = Mock.getResponse(request: request, chunkSize: chunkSize) {
            response.defaultEncoding = defaultEncoding
            if let error = response.error {
                throw error
            }
            return response
        }

        let task = session.dataTask(with: request)
        let delegate = HttpXTaskDelegate()
        delegate.chunkSize = chunkSize
        task.delegate = delegate
        task.resume()
        let response = delegate.getResponse()
        response.defaultEncoding = defaultEncoding
        if let error = response.error {
            throw error
        }
        return response
    }
}
