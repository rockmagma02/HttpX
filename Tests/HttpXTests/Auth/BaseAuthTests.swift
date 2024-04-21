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

// MARK: - BaseAuthTests

@available(macOS 10.15, *)
final class BaseAuthTests: XCTestCase {
    func testSyncAuthFlowWithRequestBody() throws {
        let mockAuth = MockBaseAuth(needRequestBody: true, needResponseBody: false)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpBodyStream = InputStream(data: "test body".data(using: .utf8)!)

        let (modifiedRequest, authDone) = try mockAuth.syncAuthFlow(request: request, lastResponse: nil)

        XCTAssertNotNil(modifiedRequest?.httpBody)
        XCTAssertNil(modifiedRequest?.httpBodyStream)
        XCTAssertFalse(authDone)
    }

    func testSyncAuthFlowWithResponseBody() throws {
        let mockAuth = MockBaseAuth(needRequestBody: false, needResponseBody: true)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let lastResponse = MockResponse(url: request.url!, statusCode: 200)!

        let (_, authDone) = try mockAuth.syncAuthFlow(request: request, lastResponse: lastResponse)

        XCTAssertTrue(lastResponse.didReadAllFormSyncStream)
        XCTAssertFalse(authDone)
    }

    func testAsyncAuthFlowWithRequestBody() async throws {
        let mockAuth = MockBaseAuth(needRequestBody: true, needResponseBody: false)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpBodyStream = InputStream(data: "test body".data(using: .utf8)!)

        let (modifiedRequest, authDone) = try await mockAuth.asyncAuthFlow(request: request, lastResponse: nil)

        XCTAssertNotNil(modifiedRequest?.httpBody)
        XCTAssertNil(modifiedRequest?.httpBodyStream)
        XCTAssertFalse(authDone)
    }

    func testAsyncAuthFlowWithResponseBody() async throws {
        let mockAuth = MockBaseAuth(needRequestBody: false, needResponseBody: true)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let lastResponse = MockResponse(url: request.url!, statusCode: 200)!

        let (_, authDone) = try await mockAuth.asyncAuthFlow(request: request, lastResponse: lastResponse)

        XCTAssertTrue(lastResponse.didReadAllFormAsyncStream)
        XCTAssertFalse(authDone)
    }
}

// MARK: - MockBaseAuth

@available(macOS 10.15, *)
private class MockBaseAuth: BaseAuth {
    // MARK: Lifecycle

    init(needRequestBody: Bool, needResponseBody: Bool) {
        self.needRequestBody = needRequestBody
        self.needResponseBody = needResponseBody
    }

    // MARK: Internal

    var needRequestBody: Bool
    var needResponseBody: Bool

    func authFlow(request: URLRequest?, lastResponse _: Response?) throws -> (URLRequest?, Bool) {
        // Mock implementation
        (request, false)
    }
}

// MARK: - MockResponse

@available(macOS 10.15, *)
private class MockResponse: Response {
    var didReadAllFormSyncStream = false
    var didReadAllFormAsyncStream = false

    override func getData() -> Data {
        didReadAllFormSyncStream = true
        return Data()
    }

    override func getData() async throws -> Data {
        didReadAllFormAsyncStream = true
        return Data()
    }
}
