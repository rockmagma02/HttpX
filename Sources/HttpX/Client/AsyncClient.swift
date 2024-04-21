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

/// Synchronous HTTP client.
@available(macOS 10.15, *)
public class AsyncClient: BaseClient {
    // MARK: Lifecycle

    deinit {}

    // MARK: Public

    /// Sends a network request asynchronously.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use for the request.
    ///     - url: The URL to which the request should be sent, should be merged with the `baseURL`.
    ///     - content: The content to send with the request. Defaults to `nil`.
    ///     - params: The query parameters to append to the URL. Defaults to `nil`, should be merged with the `params`.
    ///     - headers: The HTTP headers to send with the request. Defaults to `nil`,
    ///              should be merged with the `headers`.
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
    ) async throws -> Response {
        let request = try buildRequest(
            method: method,
            url: url,
            content: content,
            params: params,
            headers: headers,
            timeout: timeout
        )
        return try await sendRequest(
            request: request,
            auth: auth,
            followRedirects: followRedirects,
            chunkSize: chunkSize
        )
    }

    /// Sends a network request, optionally streaming the response and handling authentication and redirects.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be sent.
    ///   - stream: A tuple indicating whether the response should be streamed and the chunk size for streaming.
    ///             Defaults to `(false, nil)`, meaning no streaming.
    ///   - auth: The authentication strategy to use. If `nil`, the client's default authentication will be used.
    ///   - followRedirects: A Boolean value indicating whether the client should follow HTTP redirects.
    ///                      If `nil`, the client's default setting will be used.
    ///
    /// - Returns: A `Response` object containing the response data.
    ///
    /// - Throws: An error if the request fails.
    public func sendRequest(
        request: URLRequest,
        auth: AuthType? = nil,
        followRedirects: Bool? = nil, // swiftlint:disable:this discouraged_optional_boolean
        chunkSize: Int? = nil
    ) async throws -> Response {
        let followRedirects = followRedirects ?? self.followRedirects
        let auth = auth?.buildAuth() ?? self.auth

        return try await sendHandlingAuth(
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
    ) async throws -> Response {
        var history = history
        var (request, authStop) = try await auth.asyncAuthFlow(request: request, lastResponse: nil)

        guard request != nil else {
            throw HttpXError.invalidRequest(message: "Auth flow did not return a request")
        }

        var response = try await sendHandlingRedirect(
            request: request!,
            followRedirects: followRedirects,
            history: history,
            chunkSize: chunkSize
        )

        while !authStop {
            (request, authStop) = try await auth.asyncAuthFlow(request: request, lastResponse: response)
            if let request {
                response = try await sendHandlingRedirect(
                    request: request,
                    followRedirects: followRedirects,
                    history: history,
                    chunkSize: chunkSize
                )
                response.historyInternal = history
                history += [response]
            } else {
                break
            }
        }

        return response
    }

    internal func sendHandlingRedirect(
        request: URLRequest,
        followRedirects: Bool,
        history: [Response] = [],
        chunkSize: Int? = nil
    ) async throws -> Response {
        var request = request
        var history = history
        var response = Response(url: request.url!, error: HttpXError.invalidResponse())
        while true {
            if history.count >= maxRedirects {
                throw HttpXError.redirectError(message: "Exceeded maximum number of redirects")
            }

            eventHooks.request.forEach { $0(&request) }
            response = try await sendSingleRequest(request: request, chunkSize: chunkSize)
            eventHooks.response.forEach { $0(&response) }
            response.historyInternal = history

            guard response.hasRedirectLocation else {
                break
            }

            if followRedirects {
                _ = try await response.getData()
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
    ) async throws -> Response {
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
        let response = await delegate.getResponse()
        response.defaultEncoding = defaultEncoding
        if let error = response.error {
            throw error
        }
        return response
    }
}
