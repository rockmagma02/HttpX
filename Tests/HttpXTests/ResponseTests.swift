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
    func testStatusCodeClassify() {
        var response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 100, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isInformational)
        XCTAssertFalse(response.isSuccess)
        XCTAssertFalse(response.isError)

        response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isSuccess)
        XCTAssertFalse(response.isRedirect)

        response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 300, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isRedirect)
        XCTAssertFalse(response.isClientError)

        response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 404, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isClientError)
        XCTAssertFalse(response.isServerError)

        response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 500, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isServerError)
        XCTAssertFalse(response.isSuccess)

        response = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 404, httpVersion: nil, headerFields: nil
        )!
        XCTAssertTrue(response.isError)

        let nonResponse = URLResponse()
        XCTAssertFalse(nonResponse.isInformational)
        XCTAssertFalse(nonResponse.isSuccess)
        XCTAssertFalse(nonResponse.isRedirect)
        XCTAssertFalse(nonResponse.isClientError)
        XCTAssertFalse(nonResponse.isServerError)
        XCTAssertFalse(nonResponse.isError)
    }

    func testHasRedirectLocation() {
        let response = URLResponse()
        XCTAssertFalse(response.hasRedirectLocation)
    }

    func testStatus() {
        let response = URLResponse()
        let (status, reason) = response.status
        XCTAssertNil(status)
        XCTAssertNil(reason)
    }

    func testHeaders() {
        let response = URLResponse()
        let headers = response.allHeaders
        XCTAssertEqual(headers.count, 0)
    }

    func testDescription() {
        let response = Response()
        XCTAssertEqual(response.description, "<No Response>")

        response.error = HttpXError.invalidURL()
        XCTAssertEqual(response.description, "<Response [Error: invalidURL(message: \"\")]>")

        response.error = nil
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        XCTAssertEqual(response.description, "<Response [200 no error]>")
    }
}
