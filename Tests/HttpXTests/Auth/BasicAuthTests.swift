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

final class BasicAuthTests: XCTestCase {
    // MARK: Internal

    func testAuthFlowWithValidRequest() throws {
        let basicAuth = BasicAuth(username: "testUser", password: "testPass")
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let (modifiedRequest, didModify) = try basicAuth.authFlow(request: request, lastResponse: nil)

        XCTAssertNotNil(modifiedRequest)
        XCTAssertTrue(didModify)
        let expectedAuthHeader = buildAuthHeader(username: "testUser", password: "testPass")
        XCTAssertEqual(modifiedRequest?.value(forHTTPHeaderField: "Authorization"), expectedAuthHeader)
    }

    func testAuthFlowWithNilRequest() throws {
        let basicAuth = BasicAuth(username: "testUser", password: "testPass")

        XCTAssertThrowsError(try basicAuth.authFlow(request: nil, lastResponse: nil)) { error in
            XCTAssertEqual(error as? AuthError, AuthError.invalidRequest())
        }
    }

    func testProperty() {
        let basicAuth = BasicAuth(username: "testUser", password: "testPass")
        XCTAssertEqual(basicAuth.needRequestBody, false)
        XCTAssertEqual(basicAuth.needResponseBody, false)
    }

    // MARK: Private

    private func buildAuthHeader(username: String, password: String) -> String {
        let credentialData = "\(username):\(password)".data(using: .utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        return "Basic \(base64Credentials)"
    }
}
