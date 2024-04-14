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
public class MockResponse {
    // MARK: Lifecycle

    deinit {}

    internal init() {}

    /// Initializes a new instance of `MockResponse` with optional data, status code, and headers.
    /// - Parameters:
    ///   - request: The `URLRequest` associated with this response.
    ///   - data: The optional data to return as the response body.
    ///   - statusCode: The HTTP status code for the response. Defaults to 200.
    ///   - headers: The optional HTTP headers for the response.
    public init(
        request: URLRequest,
        data: Data? = nil,
        statusCode: Int = 200,
        headers: [String: String] = [:]
    ) {
        self.data = data
        if let url = request.url {
            URLResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headers.isEmpty ? nil : headers
            )
        }
    }

    /// Initializes a new instance of `MockResponse` with a data stream, status code, and headers.
    /// - Parameters:
    ///   - request: The `URLRequest` associated with this response.
    ///   - dataStream: An `AsyncStream<Data>` to return as the response body.
    ///   - statusCode: The HTTP status code for the response. Defaults to 200.
    ///   - headers: The optional HTTP headers for the response.
    public init(
        request: URLRequest,
        dataStream: AsyncStream<Data>,
        statusCode: Int = 200,
        headers: [String: String] = [:]
    ) {
        self.dataStream = dataStream
        if let url = request.url {
            URLResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: headers.isEmpty ? nil : headers
            )
        }
    }

    /// Initializes a new instance of `MockResponse` with an error code and message.
    /// - Parameters:
    ///   - errorCode: The error code associated with the network error.
    ///   - errorMessage: The optional error message. If not provided, an empty string is used.
    public init(
        errorCode: Int,
        errorMessage: String?
    ) {
        error = HttpXError.networkError(message: errorMessage ?? "", code: errorCode)
    }

    // MARK: Internal

    internal enum Mode {
        case async
        case sync
    }

    internal var data: Data?
    internal var dataStream: AsyncStream<Data>?
    internal var URLResponse: URLResponse?
    internal var error: (any Error)?

    internal static func getResponse(
        request: URLRequest,
        mode: Mode,
        stream: Bool,
        chunkSize: Int? = nil,
        function: @escaping (URLRequest) -> MockResponse
    ) -> Response {
        let timeout = request.timeoutInterval
        var response = MockResponse()
        let queue = DispatchQueue(label: "com.httpx.mock.\(UUID().uuidString)", attributes: .concurrent)
        let workItem = DispatchWorkItem {
            response = function(request)
        }
        queue.async(execute: workItem)
        let result = workItem.wait(timeout: .now() + timeout)
        if result == .timedOut {
            response = MockResponse(errorCode: kTimeoutCode, errorMessage: "Request timed out")
        }
        let realResponse = Response()
        realResponse.URLResponse = response.URLResponse
        realResponse.error = response.error
        response.getData(mode: mode, stream: stream, chunkSize: chunkSize, response: realResponse)
        return realResponse
    }

    // MARK: Private

    private func getDataNonStream(mode _: Mode, response: Response) {
        if let data {
            response.data = data
            return
        }
        if let stream = dataStream {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                var buffer = Data()
                for try await chunk in stream {
                    buffer.append(chunk)
                }
                self.data = buffer
                semaphore.signal()
            }
            semaphore.wait()
            response.data = data
            return
        }
    }

    private func getDataStream( // swiftlint:disable:this cyclomatic_complexity
        mode: Mode,
        chunkSize: Int?,
        response: Response
    ) {
        switch mode {
        case .sync:

            let syncResponseStream = SyncResponseStream(chunkSize: chunkSize ?? kDefaultChunkSize)
            if let data {
                try! syncResponseStream.write(data) // swiftlint:disable:this force_try
                syncResponseStream.close()
            }
            if let stream = dataStream {
                Task {
                    for try await chunk in stream {
                        try! syncResponseStream.write(chunk) // swiftlint:disable:this force_try
                    }
                    syncResponseStream.close()
                }
            }
            response.syncStream = syncResponseStream

        case .async:
            if var data {
                response.asyncStream = AsyncStream<Data> { continuation in
                    let chunkSize = chunkSize ?? kDefaultChunkSize
                    while data.count >= chunkSize {
                        continuation.yield(data.prefix(chunkSize))
                        data = data.dropFirst(chunkSize)
                    }
                    if !data.isEmpty {
                        continuation.yield(data)
                    }
                    continuation.finish()
                }
            }
            if let stream = dataStream {
                response.asyncStream = AsyncStream<Data> { continuation in
                    Task {
                        var buffer = Data()
                        let chunkSize = chunkSize ?? kDefaultChunkSize
                        for try await chunk in stream {
                            buffer.append(chunk)
                            while buffer.count >= chunkSize {
                                continuation.yield(buffer.prefix(chunkSize))
                                buffer = buffer.dropFirst(chunkSize)
                            }
                        }
                        if !buffer.isEmpty {
                            continuation.yield(buffer)
                        }
                        continuation.finish()
                    }
                }
            }
        }
    }

    private func getData(mode: Mode, stream: Bool, chunkSize: Int?, response: Response) {
        if data == nil, dataStream == nil {
            return
        }

        if !stream {
            getDataNonStream(mode: mode, response: response)
        } else {
            getDataStream(mode: mode, chunkSize: chunkSize, response: response)
        }
    }
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
        mode: MockResponse.Mode,
        stream: Bool,
        chunkSize: Int?
    ) -> Response? {
        if let url = request.url, let method = request.httpMethod {
            let netwotkLocation = url.networkLocation(percentEncoded: true)
            let path = NSString(string: url.path(percentEncoded: true)).standardizingPath
            if let route = nowUsing?.routeDict[netwotkLocation] {
                if let function = route.getFunction(
                    path: path,
                    method: HTTPMethod(rawValue: method) ?? .get
                ) {
                    return MockResponse.getResponse(
                        request: request,
                        mode: mode,
                        stream: stream,
                        chunkSize: chunkSize,
                        function: function
                    )
                }
            }
        }
        return nil
    }

    // MARK: Private

    private static var shared: Mock = .init()
    private static var nowUsing: Mock?

    private var routeDict = [NetworkLocation: Route]()
}

// swiftlint:enable legacy_objc_type
