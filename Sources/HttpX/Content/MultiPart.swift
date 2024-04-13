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

/// A class to handle multipart/form-data encoding which is often
/// used for HTTP POST requests that require file upload along with data.
public class MultiPart {
    // MARK: Lifecycle

    /// Initializes a new instance of the MultiPart class.
    /// - Parameters:
    ///   - fromData: An array of tuples containing field names and their corresponding
    ///          data. Defaults to an empty array. The corresponding data can by format
    ///          as `[Data or String]`, `Data` or `String`
    ///   - fromFile: An array of tuples containing field names and their corresponding
    ///          file information. Defaults to an empty array.
    ///   - encoding: The string encoding to use for encoding text. Defaults to `.utf8`.
    ///   - boundary: The boundary used to separate parts in the encoded form-data.
    ///          If not provided, a new UUID string will be used.
    ///
    /// - Throws: An error if the fields cannot be extracted from the provided data.
    public init(
        fromData data: [(String, Any)] = [],
        fromFile files: [(String, File)] = [],
        encoding: String.Encoding = .utf8,
        boundary: Data? = nil
    ) throws {
        self.boundary = boundary ?? UUID().uuidString.data(using: .utf8)!
        fields = try Self.getFields(fromData: data, fromFile: files, encoding: encoding)
    }

    deinit {}

    // MARK: Public

    /// Represents a file to be included in a multipart/form-data request.
    public struct File {
        /// The URL path to the file.
        public var path: URL
        /// The filename to be used in the multipart/form-data request. Optional.
        public var filename: String?
        /// The MIME type of the file. Optional.
        public var contentType: String?
        /// Additional headers to be included for this file part. defaults to an empty dictionary.
        public var headers: [String: String] = [:]
    }

    /// Calculates the total length of the multipart/form-data content.
    /// This includes the lengths of the boundaries, headers, and data for each field,
    /// as well as the final boundary.
    public var contentLength: Int {
        let boundaryLength = boundary.count
        var length = 0

        let length2 = 2
        let length4 = 4

        for field in fields {
            length += length2 + boundaryLength + length2 // "--\(boundary)\r\n"
            length += field.getLength()
            length += length2 // "\r\n"
        }

        length += length2 + boundaryLength + length4 // "--\(boundary)--\r\n"
        return length
    }

    /// Returns the headers necessary for the multipart/form-data request.
    /// - Returns: A dictionary containing the `Content-Type` and `Content-Length` headers.
    public var headers: [String: String] {
        [
            "Content-Type": contentType,
            "Content-Length": "\(contentLength)",
        ]
    }

    /// Constructs the body of the multipart/form-data request.
    /// - Returns: A `Data` object containing the constructed body of the multipart/form-data request.
    public var body: Data {
        var data = Data()
        let boundary = boundary
        for field in fields {
            data.append("--".data(using: .utf8)!)
            data.append(boundary)
            data.append("\r\n".data(using: .utf8)!)
            data.append(field.render())
            data.append("\r\n".data(using: .utf8)!)
        }
        data.append("--".data(using: .utf8)!)
        data.append(boundary)
        data.append("--\r\n".data(using: .utf8)!)
        return data
    }

    // MARK: Private

    private protocol Field {
        func renderHeaders() -> Data
        func renderData() -> Data
        func getLength() -> Int
        func render() -> Data
    }

    private class DataField: Field {
        // MARK: Lifecycle

        init(name: String, value: Data) {
            self.name = name
            self.value = value
        }

        convenience init(name: String, value: String, encoding: String.Encoding) {
            let data = value.data(using: encoding)!
            self.init(name: name, value: data)
        }

        deinit {}

        // MARK: Internal

        func renderHeaders() -> Data {
            if headers == nil {
                var name = name
                    .replacingOccurrences(of: "\"", with: "%22")
                    .replacingOccurrences(of: "\\", with: "\\\\")
                name = "name=\"\(name)\""
                let headers = [
                    "Content-Disposition: form-data; ", name, "\r\n\r\n",
                ].joined().data(using: .utf8)!
                self.headers = headers
            }
            return headers!
        }

        func renderData() -> Data {
            if data == nil {
                data = value
            }
            return data!
        }

        func getLength() -> Int {
            render().count
        }

        func render() -> Data {
            var data = Data()
            data.append(renderHeaders())
            data.append(renderData())
            return data
        }

        // MARK: Private

        private var name: String
        private var value: Data
        private var headers: Data?
        private var data: Data?
    }

    private class FileField: Field {
        // MARK: Lifecycle

        init(name: String, file: File) throws {
            self.name = name
            self.file = file

            guard let stream = InputStream(url: self.file.path) else {
                throw ContentError.pathNotFound
            }
            dataStream = stream
        }

        deinit {}

        // MARK: Internal

        func renderData() -> Data {
            if data == nil {
                data = dataStream.readAllData()
            }
            return data!
        }

        func getLength() -> Int {
            render().count
        }

        func render() -> Data {
            var data = Data()
            data.append(renderHeaders())
            data.append(renderData())
            return data
        }

        func renderHeaders() -> Data {
            if headers == nil {
                var name = name
                    .replacingOccurrences(of: "\"", with: "%22")
                    .replacingOccurrences(of: "\\", with: "\\\\")
                name = "name=\"\(name)\""

                var parts = ["Content-Disposition: form-data; ", name]
                if let filename = file.filename {
                    var filename = filename
                        .replacingOccurrences(of: "\"", with: "%22")
                        .replacingOccurrences(of: "\\", with: "\\\\")
                    filename = "filename=\"\(filename)\""
                    parts.append("; ")
                    parts.append(filename)
                }

                for (headerName, headerValue) in file.headers {
                    let key = "\r\n\(headerName): "
                    parts.append(key)
                    parts.append(headerValue)
                }

                if let contentType = file.contentType {
                    parts.append("\r\nContent-Type: ")
                    parts.append(contentType)
                }

                parts.append("\r\n\r\n")
                headers = parts.joined().data(using: .utf8)!
            }
            return headers!
        }

        // MARK: Private

        private var name: String
        private var file: File
        private var headers: Data?
        private var data: Data?
        private var dataStream: InputStream
    }

    private var fields: [Field]

    private var boundary: Data

    private var contentType: String {
        "multipart/form-data; boundary=\(String(data: boundary, encoding: .utf8)!)"
    }

    private static func getFields(
        fromData data: [(String, Any)],
        fromFile file: [(String, File)],
        encoding: String.Encoding
    ) throws -> [Field] {
        var fields: [Field] = []
        for (name, value) in data {
            if let value = value as? [Any] {
                for item in value {
                    if let item = item as? String {
                        fields.append(DataField(name: name, value: item, encoding: encoding))
                    } else if let item = item as? Data {
                        fields.append(DataField(name: name, value: item))
                    }
                }
            } else if let value = value as? String {
                fields.append(DataField(name: name, value: value, encoding: encoding))
            } else if let value = value as? Data {
                fields.append(DataField(name: name, value: value))
            }
        }

        for (name, file) in file {
            try fields.append(FileField(name: name, file: file))
        }
        return fields
    }
}
