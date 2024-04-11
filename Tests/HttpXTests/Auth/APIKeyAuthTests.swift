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

class APIKeyAuthTests: XCTestCase {
    func testAuthFlow_withValidRequest_shouldSetAPIKeyHeader() throws {
        // Given
        let apiKeyAuth = APIKeyAuth(key: "testKey")
        let request = URLRequest(url: URL(string: "https://example.com")!)

        // When
        let (modifiedRequest, shouldContinue) = try apiKeyAuth.authFlow(request: request, lastResponse: nil)

        // Then
        XCTAssertEqual(modifiedRequest?.value(forHTTPHeaderField: "x-api-key"), "testKey")
        XCTAssertTrue(shouldContinue)
    }

    func testAuthFlow_withNilRequest_shouldReturnNilAndTrue() throws {
        // Given
        let apiKeyAuth = APIKeyAuth(key: "testKey")

        // When // Then
        XCTAssertThrowsError(try apiKeyAuth.authFlow(request: nil, lastResponse: nil)) {
            XCTAssertEqual($0 as? AuthError, AuthError.invalidRequest())
        }
    }

    func testProperty() {
        let apiKeyAuth = APIKeyAuth(key: "testKey")
        XCTAssertEqual(apiKeyAuth.needRequestBody, false)
        XCTAssertEqual(apiKeyAuth.needResponseBody, false)
    }
}