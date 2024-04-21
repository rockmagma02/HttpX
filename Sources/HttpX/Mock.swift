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

// MARK: - Route

// swiftlint:disable legacy_objc_type

private class Route {
    // MARK: Lifecycle

    init(_ networkLocation: Mock.NetworkLocation) {
        self.networkLocation = networkLocation
    }

    deinit {}

    // MARK: Internal

    let networkLocation: Mock.NetworkLocation
    var path: Mock.Path = "/"
    var nextLevelRoutes = [Mock.Path: Route]()
    var functions = [HTTPMethod: (URLRequest, [Mock.Path]) -> MockResponse]()

    func addRoute(
        path: Mock.Path = "/",
        method: HTTPMethod = .get,
        function: @escaping (URLRequest, [Mock.Path]) -> MockResponse
    ) {
        var path = path
        if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        if path.isEmpty {
            functions[method] = function
            return
        }

        let parts = path.split(separator: "/", maxSplits: 1)
        let first = String(parts.first!)
        let rest = parts.count > 1 ? String(parts.last!) : "/"
        if !nextLevelRoutes.contains(where: { $0.key == first }) {
            nextLevelRoutes[first] = Route(networkLocation)
        }
        let route = nextLevelRoutes[first]!
        route.path = NSString(string: self.path + "/" + first).standardizingPath
        route.addRoute(path: rest, method: method, function: function)
    }

    func removeRoute(path: Mock.Path = "/", method: HTTPMethod = .get) -> Bool {
        var path = path
        if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        if path.isEmpty {
            functions[method] = nil
        } else {
            let parts = path.split(separator: "/", maxSplits: 1)
            let first = String(parts.first!)
            let rest = parts.count > 1 ? String(parts.last!) : "/"
            if let route = nextLevelRoutes[first] {
                if route.removeRoute(path: rest, method: method) {
                    nextLevelRoutes.removeValue(forKey: first)
                }
            }
        }
        return functions.isEmpty && nextLevelRoutes.isEmpty
    }

    func getFunction(path: Mock.Path, method: HTTPMethod) -> ((URLRequest) -> MockResponse)? {
        var function: ((URLRequest, [Mock.Path]) -> MockResponse)?
        var remainPath = [Mock.Path]()

        var path = path
        if path.hasPrefix("/") {
            path = String(path.dropFirst())
        }
        // The path exactly matches the current route
        if path.isEmpty {
            function = functions[method]
        } else {
            let parts = path.split(separator: "/", maxSplits: 1)
            let first = String(parts.first!)
            let rest = parts.count > 1 ? String(parts.last!) : "/"

            if // next route is findable, go deeper
                let route = nextLevelRoutes[first],
                let nextFunction = route.getFunction(path: rest, method: method)
            { // swiftlint:disable:this opening_brace
                return nextFunction
            }

            // function is not in deeper routes, get function from current route,
            // and pass the remain path
            function = functions[method]
            remainPath = path.components(separatedBy: "/")
        }

        if let function {
            func partial(request: URLRequest) -> MockResponse {
                function(request, remainPath)
            }
            return partial
        }
        return nil
    }

    func toJson() -> [String: Any] {
        var json = [String: Any]()
        json["path"] = path
        let functions = functions.keys.map(\.rawValue)
        if !functions.isEmpty {
            json["functions"] = functions
        }
        var next = [String: Any]()
        for (key, value) in nextLevelRoutes {
            next[key] = value.toJson()
        }
        if !next.isEmpty {
            json["next"] = next
        }
        return json
    }
}

// MARK: - MockResponse

/// A mock response used for testing HTTP requests.
public class MockResponse: Response {
    // MARK: Lifecycle

    deinit {}

    // MARK: Public

    override public func writeData(_ data: Data) {
        mockStream.continuation.yield(data)
    }

    override public func close() {
        mockStream.continuation.finish()
    }

    // MARK: Internal

    internal func toResponse(chunkSize: Int?) -> Response {
        if let chunkSize {
            Task {
                var buffer = Data()
                for try await chunk in mockStream.stream {
                    buffer.append(chunk)
                    while buffer.count >= chunkSize {
                        super.writeData(buffer.prefix(chunkSize))
                        buffer = buffer.dropFirst(chunkSize)
                    }
                }
                super.writeData(buffer)
                super.close()
            }
        } else {
            Task {
                for try await chunk in mockStream.stream {
                    super.writeData(chunk)
                }
                super.close()
            }
        }
        return self as Response
    }

    // MARK: Private

    private var mockStream:
        (stream: AsyncStream<Data>, continuation: AsyncStream<Data>.Continuation) = AsyncStream<Data>.makeStream()
}

// MARK: - Mock

/// A class to mock network requests for testing purposes.
public class Mock {
    // MARK: Lifecycle

    deinit {}

    // MARK: Public

    /// Represents a path in the URL.
    public typealias Path = String
    /// Represents a network location URL as a string.
    public typealias NetworkLocation = String

    /// Starts using the provided mock for network requests. If `nil`, uses the shared instance.
    /// - Parameter mock: The mock instance to start using. Pass `nil` to use the shared instance.
    public static func start(_ mock: Mock?) {
        nowUsing = mock == nil ? shared : mock
    }

    /// Stops using any mock for network requests, reverting to real network calls.
    public static func stop() {
        nowUsing = nil
    }

    /// Returns the shared mock instance.
    /// - Returns: The shared `Mock` instance.
    public static func getShared() -> Mock {
        shared
    }

    /// Returns the currently used mock instance, if any.
    /// - Returns: The currently used `Mock` instance, or `nil` if none is used.
    public static func getNowUsing() -> Mock? {
        nowUsing
    }

    /// Adds a route to the mock with a specific network location, path, HTTP method, and response function.
    /// - Parameters:
    ///   - networkLocation: The network location (e.g., base URL) for the route.
    ///   - path: The path for the route. Defaults to "/".
    ///   - method: The HTTP method for the route. Defaults to `.get`.
    ///   - function: The function to execute when the route is matched.
    ///         It takes a `URLRequest` and an array of paths, returning a `Response`.
    public func addRoute(
        networkLocation: String,
        path: Path = "/",
        method: HTTPMethod = .get,
        function: @escaping (URLRequest, [Path]) -> MockResponse
    ) {
        let path = NSString(string: path).standardizingPath

        if !routeDict.contains(where: { $0.key == networkLocation }) {
            routeDict[networkLocation] = Route(networkLocation)
        }

        let route = routeDict[networkLocation]!
        route.addRoute(path: path, method: method, function: function)
    }

    /// Removes a specific route from the mock.
    /// - Parameters:
    ///   - networkLocation: The network location (e.g., base URL) of the route to remove.
    ///   - path: The path of the route to remove. Defaults to "/".
    ///   - method: The HTTP method of the route to remove. Defaults to `.get`.
    public func removeRoute(
        networkLocation: String,
        path: Path = "/",
        method: HTTPMethod = .get
    ) {
        let path = NSString(string: path).standardizingPath
        if let route = routeDict[networkLocation] {
            if route.removeRoute(path: path, method: method) {
                routeDict.removeValue(forKey: networkLocation)
            }
        }
    }

    /// Removes all routes from the mock.
    public func removeAllRoutes() {
        routeDict.removeAll()
    }

    /// Converts the current state of the mock to a JSON representation.
    /// - Returns: A dictionary representing the mock's state in JSON format.
    public func toJson() -> [String: Any] {
        var json = [String: Any]()
        for (key, value) in routeDict {
            json[key] = value.toJson()
        }
        return json
    }

    // MARK: Internal

    internal static func getResponse(
        request: URLRequest,
        chunkSize: Int?
    ) -> Response? {
        if let routeCLient = nowUsing, let url = request.url, let method = request.httpMethod {
            let netwotkLocation = url.networkLocation(percentEncoded: true)
            let path = NSString(string: url.path(percentEncoded: true)).standardizingPath
            if let route = routeCLient.routeDict[netwotkLocation] {
                if let function = route.getFunction(
                    path: path,
                    method: HTTPMethod(rawValue: method) ?? .get
                ) {
                    var response = Response(url: request.url!, error: URLError(.timedOut))
                    let workItem = DispatchWorkItem {
                        response = function(request).toResponse(chunkSize: chunkSize)
                    }

                    routeCLient.queue.async(execute: workItem)
                    _ = workItem.wait(timeout: .now() + request.timeoutInterval)
                    return response
                }
            }
        }
        return nil
    }

    // MARK: Private

    private static var shared: Mock = .init()
    private static var nowUsing: Mock?

    private var routeDict = [NetworkLocation: Route]()
    private var queue = DispatchQueue(label: "com.mock.network.\(UUID().uuidString)")
}

// swiftlint:enable legacy_objc_type
