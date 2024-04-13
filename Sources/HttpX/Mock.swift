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

// MARK: - MockRoute

/// A structure representing a mock route.
private struct MockRoute {
    /// The network location to mock.
    let networkLocation: String
    /// The path of the URL to mock.
    let path: String
    /// The HTTP method to mock.
    let method: HTTPMethod

    /// The function that returns a `Response` object for the mocked request.
    let responseFunction: (URLRequest) -> (Response)

    /// A computed property to generate a unique key for the route based on its properties.
    var key: String {
        "\(networkLocation)-\(path)-\(method.rawValue)"
    }
}

// MARK: - Mock

/// A mock class for intercepting and mocking network requests.
public class Mock {
    // MARK: Lifecycle

    deinit {}

    // MARK: Public

    /// Starts the mock by initializing the shared instance.
    public static func startMock() {
        shared = Mock()
    }

    /// Stops the mock by deallocating the shared instance.
    public static func stopMock() {
        shared = nil
    }

    /// Adds a route to the mock with a specific network location, path, method, and response function.
    /// - Parameters:
    ///   - networkLocation: The network location (e.g., domain) to mock.
    ///   - path: The path of the URL to mock. Defaults to "/".
    ///   - method: The HTTP method to mock. Defaults to `.get`.
    ///   - responseFunction: The function that returns a `Response` object for the mocked request.
    public static func addRoute(
        networkLocation: String,
        path: String = "/",
        method: HTTPMethod = .get,
        responseFunction: @escaping (URLRequest) -> (Response)
    ) {
        if let mock = shared {
            let route = MockRoute(
                networkLocation: networkLocation,
                path: path,
                method: method,
                responseFunction: responseFunction
            )
            mock.routeDict[route.key] = route
        }
    }

    /// Removes a specific route from the mock.
    /// - Parameters:
    ///   - networkLocation: The network location of the route to remove.
    ///   - path: The path of the route to remove. Defaults to "/".
    ///   - method: The HTTP method of the route to remove. Defaults to `.get`.
    public static func removeRoute(
        networkLocation: String,
        path: String = "/",
        method: HTTPMethod = .get
    ) {
        if let mock = shared {
            let key = "\(networkLocation)-\(path)-\(method.rawValue)"
            mock.routeDict.removeValue(forKey: key)
        }
    }

    /// Removes all routes from the mock.
    public static func removeAllRoutes() {
        if let mock = shared {
            mock.routeDict.removeAll()
        }
    }

    // MARK: Internal

    /// Retrieves a response for a given request if a matching route exists.
    /// - Parameter request: The `URLRequest` to match against the mock routes.
    /// - Returns: A `Response` object if a matching route is found; otherwise, `nil`.
    internal static func getResponse(request: URLRequest) -> Response? {
        if let url = request.url, let mock = shared {
            let networkLocation = url.networkLocation(percentEncoded: true)
            let path = url.path(percentEncoded: true)
            let method = request.httpMethod ?? "GET"
            let key = "\(networkLocation)-\(path)-\(method)"
            if let route = mock.routeDict[key] {
                return route.responseFunction(request)
            }
        }
        return nil
    }

    // MARK: Private

    /// The shared instance of the mock.
    private static var shared: Mock?

    /// A dictionary to store the mock routes, keyed by a combination of network location, path, and method.
    private var routeDict: [String: MockRoute] = [:]
}
