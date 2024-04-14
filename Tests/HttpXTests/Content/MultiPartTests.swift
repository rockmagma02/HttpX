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

@testable import HttpX
import XCTest

class MultiPartTests: XCTestCase {
    let bundle = Bundle.module

    func testContentLength() throws {
        let dataFields: [(String, Data)] = [("key1", "value1".data(using: .utf8)!), ("key2", "value2".data(using: .utf8)!)]
        let fileURL = bundle.url(forResource: "testImage", withExtension: "png")!
        let fileFields: [(String, MultiPart.File)] = [
            ("file1", MultiPart.File(path: fileURL, filename: "testImage.png", contentType: "image/png")),
        ]

        let multiPart = try MultiPart(fromData: dataFields, fromFile: fileFields)

        let expectedLength = multiPart.contentLength
        XCTAssertGreaterThan(expectedLength, 0)
    }

    func testHeaders() throws {
        let multiPart = try MultiPart()
        let headers = multiPart.headers

        XCTAssertTrue(headers.keys.contains("Content-Type"))
        XCTAssertTrue(headers.keys.contains("Content-Length"))
        XCTAssertNotNil(Int(headers["Content-Length"]!))
    }

    func testBody() throws {
        let dataFields: [(String, Data)] = [("key1", "value1".data(using: .utf8)!)]
        let fileURL = bundle.url(forResource: "testImage", withExtension: "png")!
        let fileFields: [(String, MultiPart.File)] = [
            ("file1", MultiPart.File(path: fileURL, filename: "testImage.png", contentType: "image/png", headers: ["key": "value"])),
        ]

        let multiPart = try MultiPart(fromData: dataFields, fromFile: fileFields)
        let body = multiPart.body

        XCTAssertFalse(body.isEmpty)
    }

    func testInvalidFilePath() throws {
        let fileFields: [(String, MultiPart.File)] = [
            ("file1", MultiPart.File(path: URL(string: "invalid")!, filename: "testImage.png", contentType: "image/png")),
        ]

        XCTAssertThrowsError(try MultiPart(fromFile: fileFields)) { error in
            XCTAssertEqual(error as? ContentError, ContentError.pathNotFound)
        }
    }

    func testMultiPartInitialization() throws {
        let dataFields: [(String, Any)] = [
            ("key1", "value1"),
            ("key2", Data("value2".utf8)),
            ("key3", ["value3", Data("value3".utf8)]),
        ]
        XCTAssertNoThrow(try MultiPart(fromData: dataFields))
        let multipart = try MultiPart(fromData: dataFields)
        XCTAssertNotNil(multipart)
        XCTAssertGreaterThan(multipart.contentLength, 0)
    }

    func testMultiPartInitializationInvalid() {
        let dataFields: [(String, Any)] = [
            ("key1", 123),
        ]
        XCTAssertThrowsError(try MultiPart(fromData: dataFields)) { error in
            XCTAssertEqual(error as? ContentError, ContentError.unsupportedType)
        }
    }
}
