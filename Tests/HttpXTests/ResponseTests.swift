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
@testable import HttpX
import XCTest

final class ResponseTests: XCTestCase {
    func testResponseInit() {
        let response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertEqual(response.url, URL(string: "www.example.com")!)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.allHeaderFields, [:])

        // wrong status code
        XCTAssertNil(Response(url: URL(string: "www.example.com")!, statusCode: 1_000, headers: [:]))

        // init with HTTPURLResponse
        let httpURLResponse = HTTPURLResponse(
            url: URL(string: "www.example.com")!,
            statusCode: 200, httpVersion: nil, headerFields: ["key": "value"]
        )!
        let response2 = Response(HTTPURLResponse: httpURLResponse)!
        XCTAssertEqual(response2.url, URL(string: "www.example.com")!)
        XCTAssertEqual(response2.statusCode, 200)
        XCTAssertEqual(response2.allHeaderFields, ["Key": "value"])

        // init with error
        let error = URLError(.badURL)
        let response3 = Response(url: URL(string: "www.example.com")!, error: error)
        XCTAssertEqual(response3.error as? URLError, error)
        XCTAssertEqual(response3.url, URL(string: "www.example.com")!)
        XCTAssertEqual(response3.statusCode, -1)
    }

    func testExpectedContentLength() {
        var response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertNil(response.expectedContentLength)

        response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: ["Content-Length": "100"])!
        XCTAssertEqual(response.expectedContentLength, 100)
    }

    func testSuggestFilename() {
        var response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertNil(response.suggestedFilename)

        response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: ["Content-Disposition": "attachment; filename=\"example.txt\""])!
        XCTAssertEqual(response.suggestedFilename, "example.txt")
    }

    func testMimeType() {
        var response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertNil(response.mimeType)

        response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: ["Content-Type": "text/html"])!
        XCTAssertEqual(response.mimeType, "text/html")
    }

    func testTextEncodingName() {
        var response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertNil(response.textEncodingName)

        response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: ["Content-Type": "text/html; charset=utf-8"])!
        XCTAssertEqual(response.textEncodingName, "utf-8")
        XCTAssertEqual(response.defaultEncoding, String.Encoding.utf8)
    }

    func testHasRedirectLocation() {
        var response = Response(url: URL(string: "www.example.com")!, statusCode: 200, headers: [:])!
        XCTAssertFalse(response.hasRedirectLocation)

        response = Response(url: URL(string: "www.example.com")!, statusCode: 301, headers: ["Location": "www.example.com"])!
        XCTAssertTrue(response.hasRedirectLocation)
    }

    func testDescription() {
        let response = Response(url: URL(string: "http://example.com")!, error: URLError(.badURL))
        XCTAssertTrue(response.description.hasPrefix("<Response [Error:"))

        let response2 = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])
        XCTAssertEqual(response2?.description, "<Response [200 no error]>")
    }

    func testStatusCodeClassify() {
        var response = Response(url: URL(string: "http://example.com")!, statusCode: 100, headers: [:])!
        XCTAssertTrue(response.isInformational)
        XCTAssertFalse(response.isSuccess)
        XCTAssertFalse(response.isError)

        response = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        XCTAssertTrue(response.isSuccess)
        XCTAssertFalse(response.isRedirect)

        response = Response(url: URL(string: "http://example.com")!, statusCode: 300, headers: [:])!
        XCTAssertTrue(response.isRedirect)
        XCTAssertFalse(response.isClientError)

        response = Response(url: URL(string: "http://example.com")!, statusCode: 404, headers: [:])!
        XCTAssertTrue(response.isClientError)
        XCTAssertFalse(response.isServerError)

        response = Response(url: URL(string: "http://example.com")!, statusCode: 500, headers: [:])!
        XCTAssertTrue(response.isServerError)
        XCTAssertFalse(response.isSuccess)

        response = Response(url: URL(string: "http://example.com")!, statusCode: 404, headers: [:])!
        XCTAssertTrue(response.isError)
    }

    func testSetError() {
        let response = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        XCTAssertNil(response.error)

        response.error = URLError(.badURL)
        XCTAssertEqual(response.error as? URLError, URLError(.badURL))

        response.error = nil
        XCTAssertNil(response.error)
    }

    func testData() {
        let response = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response.close()
        XCTAssertEqual(response.getData(), Data())
        XCTAssertEqual(response.getText(), "")
        XCTAssertNil(response.getJSON())

        let response2 = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response2.writeData(String("Hello").data(using: .utf8)!)
        response2.writeData(String(", ").data(using: .utf8)!)
        response2.writeData(String("World").data(using: .utf8)!)
        response2.writeData(String("!").data(using: .utf8)!)
        response2.close()

        var dataArray: [Data] = []
        for data in response2 {
            dataArray.append(data)
        }
        XCTAssertEqual(dataArray.count, 4)
        XCTAssertEqual(dataArray[0], String("Hello").data(using: .utf8)!)
        XCTAssertEqual(dataArray[1], String(", ").data(using: .utf8)!)
        XCTAssertEqual(dataArray[2], String("World").data(using: .utf8)!)
        XCTAssertEqual(dataArray[3], String("!").data(using: .utf8)!)

        XCTAssertEqual(response2.getData(), String("Hello, World!").data(using: .utf8)!)
        XCTAssertEqual(response2.getText(), "Hello, World!")
        XCTAssertNil(response2.getJSON())

        let response3 = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response3.writeData("{\"key\": \"value\"}".data(using: .utf8)!)
        response3.close()

        XCTAssertEqual(response3.getData(), "{\"key\": \"value\"}".data(using: .utf8)!)
        XCTAssertEqual(response3.getText(), "{\"key\": \"value\"}")
        XCTAssertEqual(response3.getJSON() as? [String: String], ["key": "value"])
    }

    func testData() async throws {
        let response = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response.close()

        var data: Data
        data = try await response.getData()
        XCTAssertEqual(data, Data())
        var text: String
        text = try await response.getText()
        XCTAssertEqual(text, "")
        var json: Any?
        json = try await response.getJSON()
        XCTAssertNil(json)

        let response2 = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response2.writeData(String("Hello").data(using: .utf8)!)
        response2.writeData(String(", ").data(using: .utf8)!)
        response2.writeData(String("World").data(using: .utf8)!)
        response2.writeData(String("!").data(using: .utf8)!)
        response2.close()

        var dataArray: [Data] = []
        for try await data in response2 {
            dataArray.append(data)
        }
        XCTAssertEqual(dataArray.count, 4)
        XCTAssertEqual(dataArray[0], String("Hello").data(using: .utf8)!)
        XCTAssertEqual(dataArray[1], String(", ").data(using: .utf8)!)
        XCTAssertEqual(dataArray[2], String("World").data(using: .utf8)!)
        XCTAssertEqual(dataArray[3], String("!").data(using: .utf8)!)

        data = try await response2.getData()
        XCTAssertEqual(data, String("Hello, World!").data(using: .utf8)!)
        text = try await response2.getText()
        XCTAssertEqual(text, "Hello, World!")
        json = try await response2.getJSON()
        XCTAssertNil(json)

        let response3 = Response(url: URL(string: "http://example.com")!, statusCode: 200, headers: [:])!
        response3.writeData("{\"key\": \"value\"}".data(using: .utf8)!)
        response3.close()

        data = try await response3.getData()
        XCTAssertEqual(data, "{\"key\": \"value\"}".data(using: .utf8)!)
        text = try await response3.getText()
        XCTAssertEqual(text, "{\"key\": \"value\"}")
        json = try await response3.getJSON()
        XCTAssertEqual(json as? [String: String], ["key": "value"])
    }
}
