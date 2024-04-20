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
import os.log

// MARK: - ResponseNew

public class ResponseNew: CustomStringConvertible, IteratorProtocol, Sequence, AsyncIteratorProtocol, AsyncSequence {
    // MARK: Lifecycle

    /// Initialize the Response with url, statusCode and headers.
    /// - Parameters:
    ///     - url: The url of the response.
    ///     - statusCode: The status code of the response.
    ///     - headers: The headers of the response. default is empty.
    ///
    /// Note: The status code must be valid, otherwise the init will return nil.
    public init?(
        url: URL,
        statusCode: Int,
        headers: [String: String] = [:]
    ) {
        urlPrivate = url
        guard Self.validStatusCodes.contains(statusCode) else {
            return nil
        }
        statusCodePrivate = statusCode
        headersPrivate = headers
    }

    /// Initialize the Response with HTTPURLResponse.
    /// - Parameters:
    ///     - HTTPURLResponse: The HTTPURLResponse in Foundation.
    ///
    /// Note: The HTTPURLResponse must have a valid url, otherwise the init
    /// will return nil.
    public init?(HTTPURLResponse: HTTPURLResponse) {
        guard let url = HTTPURLResponse.url else {
            return nil
        }
        urlPrivate = url
        statusCodePrivate = HTTPURLResponse.statusCode
        for (key, value) in HTTPURLResponse.allHeaderFields {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            headersPrivate[standardlizeHeaderKey(key)] = value
        }
    }

    /// Initialize the Response when error occurred.
    /// - Parameters:
    ///     - url: The url of the response.
    ///     - error: The error of the response.
    public init(url: URL, error: any Error) {
        urlPrivate = url
        statusCodePrivate = -1
        self.error = error
    }

    deinit {}

    // MARK: Public

    /// The default encoding of the response, which can be set by user.
    public var defaultEncoding: String.Encoding = .utf8

    // MARK: URL

    /// The url of the response.
    public var url: URL { urlPrivate }

    // MARK: Headers

    /// The headers of the response.
    public var allHeaderFields: [String: String] { headersPrivate }

    /// The Content-Length from the headers.
    public var expectedContentLength: Int64? {
        let lengthText = value(forHTTPHeaderField: "Content-Length")
        guard let length = lengthText else {
            return nil
        }
        return Int64(length)
    }

    /// The suggested filename from the headers.
    public var suggestedFilename: String? {
        // use regex to find value after filename=
        let regex = try! NSRegularExpression(pattern: "filename=(.*)", options: []) // swiftlint:disable:this force_try
        let header = value(forHTTPHeaderField: "Content-Disposition") ?? ""
        let range = NSRange(location: 0, length: header.utf16.count)
        let match = regex.firstMatch(in: header, options: [], range: range)
        guard let match else {
            return nil
        }
        let nsRange = match.range(at: 1)
        guard let range = Range(nsRange, in: header) else {
            return nil
        }
        var filename = String(header[range])
        if filename.hasPrefix("\"") {
            filename.removeFirst()
        }
        if filename.hasSuffix("\"") {
            filename.removeLast()
        }
        return filename
    }

    /// The MIME type from the headers.
    public var mimeType: String? {
        value(forHTTPHeaderField: "Content-Type")
    }

    /// The text encoding name from the headers.
    public var textEncodingName: String? {
        value(forHTTPHeaderField: "Content-Type")?.components(separatedBy: "charset=").last
    }

    /// Determines if the response has a redirect location.
    public var hasRedirectLocation: Bool {
        [301, 302, 303, 307, 308].contains(statusCode) // swiftlint:disable:this no_magic_numbers
            && headersPrivate.keys.contains("Location")
    }

    // MARK: Status

    /// The status codes of the response.
    public var statusCode: Int { statusCodePrivate }

    /// The status message of the response.
    public var status: String { HTTPURLResponse.localizedString(forStatusCode: statusCode) }

    /// The description of the response, usually look like "<Response [200 OK]>".
    public var description: String {
        if statusCode != -1 {
            return "<Response [\(statusCode) \(status)]>"
        }

        if let error {
            return "<Response [Error: \(error)]>"
        }

        return "<No Response>"
    }

    /// Determines if the status code is informational (100-199).
    public var isInformational: Bool {
        (100 ... 199).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    /// Determines if the status code indicates success (200-299).
    public var isSuccess: Bool {
        (200 ... 299).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    /// Determines if the status code indicates a redirection (300-399).
    public var isRedirect: Bool {
        (300 ... 399).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    /// Determines if the status code indicates a client error (400-499).
    public var isClientError: Bool {
        (400 ... 499).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    /// Determines if the status code indicates a server error (500-599).
    public var isServerError: Bool {
        (500 ... 599).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    /// Determines if the status code indicates any type of error (400-599).
    public var isError: Bool {
        (400 ... 599).contains(statusCode) // swiftlint:disable:this no_magic_numbers
    }

    // MARK: Error

    /// The error of the response.
    public var error: (any Error)? {
        get {
            errorPrivate
        }
        set {
            errorPrivate = newValue == nil ? nil : buildError(newValue!)
        }
    }

    public var numberOfBytesReceived: Int {
        data.count
    }

    // MARK: Header Functions

    /// Get the value of the header field, the field name is case-insensitive.
    public func value(forHTTPHeaderField field: String) -> String? {
        let key = standardlizeHeaderKey(field)
        return headersPrivate[key]
    }

    /// Stop to receive the data from the bytes-stream.
    public func close() {
        stream.continuation.finish()
    }

    public func next() async throws -> Data? {
        if iterator == nil {
            iterator = stream.stream.makeAsyncIterator()
        }
        let data = await iterator!.next()
        if let data {
            self.data.append(data)
        } else {
            readFinished = true
        }
        return data
    }

    @available(*, noasync, message: "this method blocks thread, recommend to use async method")
    public func next() -> Data? {
        var data: Data?
        nextWithCompletionHandler { result in
            data = result
            self.semaphore.signal()
        }
        semaphore.wait()
        return data
    }

    public func makeIterator() -> ResponseNew {
        if mode == .idle {
            mode = .sync
        }
        if mode != .sync {
            logger.fault(
                "The response is already in async mode, invoking `makeIterator()` might cause data loss"
            )
        }

        return self
    }

    public func makeAsyncIterator() -> ResponseNew {
        if mode == .idle {
            mode = .async
        }
        if mode != .async {
            logger.fault(
                "The response is already in sync mode, invoking `makeAsyncIterator()` might cause data loss"
            )
        }

        return self
    }

    /// get the data from the response
    public func getData() -> Data {
        while !readFinished {
            _ = next()
        }
        return data
    }

    /// get the data from the response, in async way
    public func getData() async throws -> Data {
        while !readFinished {
            _ = try await next()
        }
        return data
    }

    /// get the text from the response
    public func getText() -> String {
        let encoding = nameToEncoding(textEncodingName ?? "") ?? defaultEncoding
        return String(data: getData(), encoding: encoding) ?? ""
    }

    /// get the text from the response, in async way
    public func getText() async throws -> String {
        let encoding = nameToEncoding(textEncodingName ?? "") ?? defaultEncoding
        return try await String(data: getData(), encoding: encoding) ?? ""
    }

    /// get the json from the response
    public func getJSON() -> Any? {
        try? JSONSerialization.jsonObject(with: getData())
    }

    /// get the json from the response, in async way
    public func getJSON() async throws -> Any? {
        try? await JSONSerialization.jsonObject(with: try getData())
    }

    // MARK: Internal

    internal func writeData(_ data: Data) {
        stream.continuation.yield(data)
    }

    // MARK: Private

    private enum Mode {
        case idle
        case async
        case sync
    }

    // swiftlint:disable no_magic_numbers
    private static let validStatusCodes = [
        100, 101, 102, 103, 200, 201, 202, 203, 204, 205, 206, 207, 208, 226,
        300, 301, 302, 303, 304, 305, 306, 307, 308, 400, 401, 402, 403, 404,
        405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418,
        421, 422, 423, 424, 425, 426, 428, 429, 431, 451, 500, 501, 502, 503,
        504, 505, 506, 507, 508, 510, 511, -1,
        // -1 is a custom status code for no response
    ]

    // swiftlint:enable no_magic_numbers

    private let logger = Logger(subsystem: "com.httpx", category: "Response")
    private var urlPrivate: URL
    private var statusCodePrivate: Int
    private var headersPrivate: [String: String] = [:]
    private var errorPrivate: (any Error)?
    private var stream:
        (stream: AsyncStream<Data>, continuation: AsyncStream<Data>.Continuation) = AsyncStream<Data>.makeStream()
    private var iterator: AsyncStream<Data>.AsyncIterator?
    private var semaphore = DispatchSemaphore(value: 0)
    private var data = Data()
    private var readFinished = false

    private var mode: Mode = .idle

    private func nextWithCompletionHandler(_ completionHandler: @escaping (Data?) -> Void) {
        Task {
            try? await completionHandler(next())
        }
    }

    private func standardlizeHeaderKey(_ key: String) -> String {
        key.capitalized
    }
}
