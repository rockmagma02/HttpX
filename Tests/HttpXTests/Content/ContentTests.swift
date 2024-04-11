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

class ContentTests: XCTestCase {
    func testEncodeContentWithData() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let testData = "Test Data".data(using: .utf8)!
        let content = Content.data(testData)

        try content.encodeContent(request: &request)

        XCTAssertEqual(request.httpBody, testData)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Length"), testData.count.description)
    }

    func testEncodeContentWithText() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let testText = "Test Text"
        let content = Content.text(testText)

        try content.encodeContent(request: &request)

        XCTAssertEqual(request.httpBody, testText.data(using: .utf8))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Length"), testText.count.description)
    }

    func testEncodeContentWithURLEncoded() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let testData = [("key1", "value1"), ("key2", "value2")]
        let content = Content.urlEncoded(testData)

        try content.encodeContent(request: &request)

        let expectedBody = "key1=value1&key2=value2"
        XCTAssertEqual(request.httpBody, expectedBody.data(using: .utf8))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Length"), expectedBody.count.description)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    }

    func testEncodeContentWithMultipart() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let testData = try MultiPart()
        let content = Content.multipart(testData)

        try content.encodeContent(request: &request)

        XCTAssertEqual(request.httpBody, testData.body)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), testData.headers["Content-Type"])
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Length"), testData.headers["Content-Length"])
    }

    func testEncodeContentWithJSON() throws {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let testData: [String: Any] = ["key": "value"]
        let content = Content.json(testData)

        try content.encodeContent(request: &request)

        let expectedData = try JSONSerialization.data(withJSONObject: testData, options: [])
        XCTAssertEqual(request.httpBody, expectedData)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Length"), expectedData.count.description)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
}
