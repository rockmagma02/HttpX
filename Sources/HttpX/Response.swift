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

// MARK: - Response

/// Represents an HTTP response.
@available(macOS 10.15, *)
public class Response: CustomStringConvertible {
    // MARK: Lifecycle

    deinit {}

    public init(URLResponse: URLResponse? = nil, data: Data? = nil) {
        self.URLResponse = URLResponse
        self.data = data
    }

    // MARK: Public

    /// The data received in the response.
    public var data: Data?

    /// The next request to be made,
    /// when redirects aren't followed automatically, but redirection is needed.
    public var nextRequest: URLRequest?

    /// The history of previous responses,
    /// when redirects are followed, multi-step Authorization is used, etc.
    public var history: [Response] = []

    /// The stream data from SyncClient.
    public var syncStream: SyncResponseStream?

    /// The stream data from AsyncClient.
    public var asyncStream: AsyncStream<Data>?

    /// The `Foundation.URLresponse` received.
    public var URLResponse: URLResponse? {
        didSet {
            errorAndResponseSignal.signal()
        }
    }

    /// The error occurred during the request, if any.
    public var error: (any Error)? {
        didSet {
            errorAndResponseSignal.signal()
        }
    }

    /// The description of the response, usually look like "<Response [200 OK]>".
    public var description: String {
        if let statusCode {
            return "<Response [\(statusCode) \(URLResponse!.status.1!)]>"
        }

        if let error {
            return "<Response [Error: \(error)]>"
        }

        return "<No Response>"
    }

    /// The HTTP status code of the response.
    public var statusCode: Int? {
        URLResponse?.status.0
    }

    /// Reads all data from the synchronous stream and stores it in the `data` property.
    public func readAllFormSyncStream() {
        if let stream = syncStream {
            var data = Data()
            for chunk in stream {
                data.append(chunk)
            }
            self.data = data
        }
    }

    /// Reads all data from the asynchronous stream and stores it in the `data` property.
    public func readAllFormAsyncStream() async {
        if let stream = asyncStream {
            var data = Data()
            for try await chunk in stream {
                data.append(chunk)
            }
            self.data = data
        }
    }

    // MARK: Internal

    internal func waitForErrorAndResponse() {
        if URLResponse == nil, error == nil {
            errorAndResponseSignal.wait()
        }
    }

    // MARK: Private

    private var errorAndResponseSignal = DispatchSemaphore(value: 0)
}

/// Extension Foundation.URLResponse
public extension URLResponse {
    /// The HTTP status code and localized status description.
    var status: (Int?, String?) {
        guard let httpResponse = self as? HTTPURLResponse else {
            return (nil, nil)
        }
        let statusCode = httpResponse.statusCode
        return (statusCode, HTTPURLResponse.localizedString(forStatusCode: statusCode))
    }

    /// All header fields of the response.
    var allHeaders: [AnyHashable: Any] {
        (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }

    /// Retrieves the value for a given HTTP header field.
    /// - Parameter field: The name of the header field.
    /// - Returns: The value of the header field, if available.
    func getHeaderValue(forHTTPHeaderField field: String) -> String? {
        allHeaders[field] as? String
    }

    /// Determines if the status code is informational (100-199).
    var isInformational: Bool {
        if let statusCode = status.0 {
            return (100 ... 199).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the status code indicates success (200-299).
    var isSuccess: Bool {
        if let statusCode = status.0 {
            return (200 ... 299).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the status code indicates a redirection (300-399).
    var isRedirect: Bool {
        if let statusCode = status.0 {
            return (300 ... 399).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the status code indicates a client error (400-499).
    var isClientError: Bool {
        if let statusCode = status.0 {
            return (400 ... 499).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the status code indicates a server error (500-599).
    var isServerError: Bool {
        if let statusCode = status.0 {
            return (500 ... 599).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the status code indicates any type of error (400-599).
    var isError: Bool {
        if let statusCode = status.0 {
            return (400 ... 599).contains(statusCode) // swiftlint:disable:this no_magic_numbers
        }
        return false
    }

    /// Determines if the response has a redirect location.
    var hasRedirectLocation: Bool {
        guard let stateCode = status.0 else {
            return false
        }

        let headersKey = allHeaders.keys.map { $0 as? String }
        return [301, 302, 303, 307, 308].contains(stateCode) // swiftlint:disable:this no_magic_numbers
            && headersKey.contains("Location")
    }
}
