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
import SyncStream
import XCTest

// MARK: - BaseAuthTests

@available(macOS 10.15, *)
final class BaseAuthTests: XCTestCase {
    func testSyncAuthFlowWithRequestBody() throws {
        let mockAuth = MockBaseAuth(needRequestBody: true, needResponseBody: false)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpBodyStream = InputStream(data: "test body".data(using: .utf8)!)
        let authFlow = mockAuth.authFlowAdapter(request)
        let modifiedRequest = try authFlow.next()
        XCTAssertNotNil(modifiedRequest.httpBody)
        XCTAssertNil(modifiedRequest.httpBodyStream)
    }

    func testSyncAuthFlowWithRequestBodyAsync() async throws {
        let mockAuth = MockBaseAuth(needRequestBody: true, needResponseBody: false)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpBodyStream = InputStream(data: "test body".data(using: .utf8)!)
        let authFlow = await mockAuth.authFlowAdapter(request)
        let modifiedRequest = try await authFlow.next()
        XCTAssertNotNil(modifiedRequest.httpBody)
        XCTAssertNil(modifiedRequest.httpBodyStream)
    }

    func testSyncAuthFlowWithResponseBody() throws {
        let mockAuth = MockBaseAuth(needRequestBody: false, needResponseBody: true)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let lastResponse = MockResponse(url: request.url!, statusCode: 200)!

        let authFlow = mockAuth.authFlowAdapter(request)
        _ = try authFlow.next()
        _ = try authFlow.send(lastResponse)

        XCTAssertTrue(lastResponse.didReadAllFormSyncStream)
    }

    func testSyncAuthFlowWithResponseBodyAsync() async throws {
        let mockAuth = MockBaseAuth(needRequestBody: false, needResponseBody: true)
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let lastResponse = MockResponse(url: request.url!, statusCode: 200)!

        let authFlow = await mockAuth.authFlowAdapter(request)
        _ = try await authFlow.next()
        _ = try await authFlow.send(lastResponse)

        XCTAssertTrue(lastResponse.didReadAllFormAsyncStream)
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

    func authFlow(_ request: URLRequest, continuation: BidirectionalSyncStream<URLRequest, Response, NoneType>.Continuation) {
        let _ = continuation.yield(request)
        let _ = continuation.yield(request)
        continuation.return(NoneType())
    }

    func authFlow(_ request: URLRequest, continuation: BidirectionalAsyncStream<URLRequest, Response, NoneType>.Continuation) async {
        let _ = await continuation.yield(request)
        let _ = await continuation.yield(request)
        await continuation.return(NoneType())
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
