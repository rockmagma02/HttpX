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

// API for HttpX

/// Performs a synchronous HTTP request.
///
/// - Parameters:
/// - method: The HTTP method to use for the request.
/// - url: The URL to send the request to.
/// - params: The query parameters to include in the request.
/// - content: The content to include in the request body.
/// - headers: The headers to include in the request.
/// - cookies: The cookies to include in the request.
/// - auth: The authentication information to include in the request.
/// - timeout: The timeout interval for the request.
/// - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func request(
    method: HTTPMethod,
    url: URLType,
    params: QueryParamsType? = nil,
    content: Content? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try SyncClient(
        cookies: cookies,
        timeout: timeout
    ).request(
        method: method,
        url: url,
        content: content,
        params: params,
        headers: headers,
        auth: auth,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a synchronous GET request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func get(
    url: URLType,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try request(
        method: .get,
        url: url,
        params: params,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a synchronous POST request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func post(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try request(
        method: .post,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a synchronous PUT request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func put(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try request(
        method: .put,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a synchronous PATCH request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func patch(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try request(
        method: .patch,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a synchronous DELETE request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func delete(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) throws -> Response {
    try request(
        method: .delete,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous HTTP request.
///
/// - Parameters:
/// - method: The HTTP method to use for the request.
/// - url: The URL to send the request to.
/// - params: The query parameters to include in the request.
/// - content: The content to include in the request body.
/// - headers: The headers to include in the request.
/// - cookies: The cookies to include in the request.
/// - auth: The authentication information to include in the request.
/// - timeout: The timeout interval for the request.
/// - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func request(
    method: HTTPMethod,
    url: URLType,
    params: QueryParamsType? = nil,
    content: Content? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await AsyncClient(
        cookies: cookies,
        timeout: timeout
    ).request(
        method: method,
        url: url,
        content: content,
        params: params,
        headers: headers,
        auth: auth,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous GET request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func get(
    url: URLType,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await request(
        method: .get,
        url: url,
        params: params,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous POST request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func post(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await request(
        method: .post,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous PUT request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func put(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await request(
        method: .put,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous PATCH request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func patch(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await request(
        method: .patch,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}

/// Performs a asynchronous DELETE request.
///
/// - Parameters:
///   - url: The URL to send the request to.
///   - content: The content to include in the request body.
///   - params: The query parameters to include in the request.
///   - headers: The headers to include in the request.
///   - cookies: The cookies to include in the request.
///   - auth: The authentication information to include in the request.
///   - timeout: The timeout interval for the request.
///   - followRedirects: A boolean value indicating whether to follow redirects.
///
/// - Returns: The response received from the server.
///
/// - Throws: An error if the request fails.
public func delete(
    url: URLType,
    content: Content? = nil,
    params: QueryParamsType? = nil,
    headers: HeadersType? = nil,
    cookies: CookiesType? = nil,
    auth: AuthType? = nil,
    timeout: Timeout = .init(),
    followRedirects: Bool = false,
    chunkSize: Int? = nil
) async throws -> Response {
    try await request(
        method: .delete,
        url: url,
        params: params,
        content: content,
        headers: headers,
        cookies: cookies,
        auth: auth,
        timeout: timeout,
        followRedirects: followRedirects,
        chunkSize: chunkSize
    )
}
