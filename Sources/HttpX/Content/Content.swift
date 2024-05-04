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

/// An enumeration representing different types of content that can be encoded and attached to a URLRequest.
public enum Content {
    /// Represents raw binary data, should provide Content-type manually.
    case data(Data)
    /// Represents JSON data.
    case json(Any)
    /// Represents multipart form data.
    case multipart(MultiPart)
    /// Represents a stream of data.
    case stream(InputStream)
    /// Represents raw text data, should provide Content-type manually.
    case text(String)
    /// Represents URL encoded form data.
    case urlEncoded([(String, String)])

    // MARK: Public

    /// Encodes the content into the given URLRequest.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to encode the content into. This parameter is inout, meaning it will be modified.
    ///   - encode: The string encoding to use for encoding text. Defaults to `.utf8`.
    /// - Throws: An error if encoding fails, particularly for JSON content.
    public func encodeContent(request: inout URLRequest, encode: String.Encoding = .utf8) throws {
        switch self {
        case let .data(data):
            request.httpBody = data
            request.setValue(data.count.description, forHTTPHeaderField: "Content-Length")

        case let .stream(stream):
            request.httpBodyStream = stream

        case let .text(text):
            request.httpBody = text.data(using: encode)
            request.setValue(text.count.description, forHTTPHeaderField: "Content-Length")

        case let .urlEncoded(data):
            let body = urlEncode(query: data)
            request.httpBody = body.data(using: encode)
            request.setValue(body.count.description, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        case let .multipart(data):
            request.httpBody = data.body
            let headers = data.headers
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }

        case let .json(json):
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = data
            request.setValue(data.count.description, forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    // MARK: Private

    private func urlEncode(query: [(String, String)]) -> String {
        var components: [String] = []
        for (key, value) in query {
            components.append("\(key)=\(value)")
        }
        return components.joined(separator: "&")
    }
}
