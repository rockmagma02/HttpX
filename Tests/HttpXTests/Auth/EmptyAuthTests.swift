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

final class EmptyAuthTests: XCTestCase {
    var emptyAuth: EmptyAuth!

    override func setUp() {
        super.setUp()
        emptyAuth = EmptyAuth()
    }

    override func tearDown() {
        emptyAuth = nil
        super.tearDown()
    }

    func testNeedRequestBody() {
        XCTAssertFalse(emptyAuth.needRequestBody)
    }

    func testNeedResponseBody() {
        XCTAssertFalse(emptyAuth.needResponseBody)
    }

    func testAuthFlow() throws {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let authFlow = emptyAuth.authFlowAdapter(request)
        let modifiedRequest = try authFlow.next()

        XCTAssertEqual(modifiedRequest, request)
    }

    func testAuthFlowAsync() async throws {
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let authFlow = await emptyAuth.authFlowAdapter(request)
        let modifiedRequest = try await authFlow.next()

        XCTAssertEqual(modifiedRequest, request)
    }
}
