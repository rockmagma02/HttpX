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

private let kDefaultTimeoutNumber = 30
/// Default timeout for network requests in seconds.
public let kDefaultTimeout = TimeInterval(kDefaultTimeoutNumber)
/// Maximum number of redirects allowed for a network request.
public let kDefaultMaxRedirects = 20

internal let kTimeoutCode = -1_001

// MARK: - HTTPMethod

// swiftlint:disable file_types_order
// swiftlint:disable sorted_enum_cases
public enum HTTPMethod: String {
    /// The GET method requests a representation of the specified resource.
    /// Requests using GET should only retrieve data.
    case get = "GET"

    /// The HEAD method asks for a response identical to a GET request, but without the response body.
    case head = "HEAD"

    /// The POST method submits an entity to the specified resource,
    /// often causing a change in state or side effects on the server.
    case post = "POST"

    /// The PUT method replaces all current representations of the target resource with the request payload.
    case put = "PUT"

    /// The DELETE method deletes the specified resource.
    case delete = "DELETE"

    /// The CONNECT method establishes a tunnel to the server identified by the target resource.
    case connect = "CONNECT"

    /// The OPTIONS method describes the communication options for the target resource.
    case options = "OPTIONS"

    /// The TRACE method performs a message loop-back test along the path to the target resource.
    case trace = "TRACE"

    /// The PATCH method applies partial modifications to a resource.
    case patch = "PATCH"
}

// MARK: - URLType

// swiftlint:enable sorted_enum_cases

/// Represents the type of HTTP method used in HTTP requests.
public enum URLType {
    /// Represents a URL wrapped in a class.
    case `class`(URL)

    /// Represents a URL using URLComponents.
    case components(URLComponents)

    /// Represents a URL as a string.
    case string(String)

    // MARK: Public

    /// Builds a URL based on the URLType instance.
    /// - Returns: An optional URL. Returns `nil` if the URL cannot be constructed.
    public func buildURL() -> URL? {
        switch self {
        case let .class(url):
            url

        case let .components(urlComponents):
            urlComponents.url

        case let .string(string):
            URL(string: string)
        }
    }
}

// MARK: - QueryParamsType

/// Represents the type of query parameters that can be used in HTTP requests.
public enum QueryParamsType {
    /// Represents query parameters as a class containing an array of `URLQueryItem` objects.
    case `class`([URLQueryItem])

    /// Represents query parameters as an array of key-value pairs.
    case array([(String, String)])

    /// Represents query parameters as a dictionary of key-value pairs.
    case dictionary([String: String])

    // MARK: Public

    /// Builds an array of URLQueryItem from the QueryParamsType instance.
    /// - Returns: An array of URLQueryItem.
    public func buildQueryItems() -> [URLQueryItem] {
        switch self {
        case let .class(queryItems):
            queryItems

        case let .array(array):
            array.map { URLQueryItem(name: $0.0, value: $0.1) }

        case let .dictionary(dictionary):
            dictionary.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
    }
}

// MARK: - HeadersType

/// Represents the type of headers used in HTTP requests.
public enum HeadersType {
    /// An array of key-value pairs representing the headers.
    case array([(String, String)])

    /// A dictionary representing the headers.
    case dictionary([String: String])

    // MARK: Public

    /// Builds a dictionary of headers from the HeadersType instance.
    /// - Returns: A dictionary representing the headers.
    public func buildHeaders() -> [(String, String)] {
        switch self {
        case let .array(array):
            array

        case let .dictionary(dictionary):
            dictionary.map { ($0.key, $0.value) }
        }
    }
}

// MARK: - CookiesType

/// Represents the type of cookies that can be used in HTTP requests.
public enum CookiesType {
    /// An array of key-value-domain-path pairs representing HTTP headers.
    case array([(String, String, String, String?)])

    /// An array of HTTP cookies.
    case cookieArray([HTTPCookie])

    /// The storage for HTTP cookies.
    case storage(HTTPCookieStorage)

    // MARK: Public

    /// Builds cookies from the CookiesType instance.
    public func buildCookies() -> [HTTPCookie] {
        switch self {
        case let .array(array):
            array
                .map { HTTPCookie(properties: [.name: $0.0, .value: $0.1, .domain: $0.2, .path: $0.3 ?? "/"]) }
                .compactMap { $0 }

        case let .cookieArray(cookies):
            cookies

        case let .storage(storage):
            storage.cookies ?? []
        }
    }
}

// MARK: - AuthType

/// Represents the type of authentication used in network requests.
public enum AuthType {
    /// Authentication using a class that conforms to `BaseAuth`.
    case `class`(any BaseAuth)
    /// Authentication using a custom function.
    case `func`((URLRequest) -> URLRequest)
    /// Basic authentication using a username and password.
    case basic((String, String))

    // MARK: Public

    /// Builds the appropriate `BaseAuth` instance based on the `AuthType`.
    public func buildAuth() -> any BaseAuth {
        switch self {
        case let .class(auth):
            auth

        case let .basic(basic):
            BasicAuth(username: basic.0, password: basic.1)

        case let .func(funcAuth):
            FunctionAuth(authFunction: funcAuth)
        }
    }
}

// MARK: - EventHooks

/// Represents hooks for modifying requests and responses in the networking layer.
public struct EventHooks {
    // MARK: Lifecycle

    /// Initializes a new instance of `EventHooks`.
    /// - Parameters:
    ///   - request: An array of closures that modify `URLRequest` objects.
    ///   - response: An array of closures that modify `Response` objects.
    public init(request: [(inout URLRequest) -> Void] = [], response: [(inout Response) -> Void] = []) {
        self.request = request
        self.response = response
    }

    // MARK: Public

    /// An array of closures that are applied to `URLRequest` objects.
    public var request: [(inout URLRequest) -> Void] = []
    /// An array of closures that are applied to `Response` objects.
    public var response: [(inout Response) -> Void] = []
}

// swiftlint:enable file_types_order
