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

class FunctionAuthTests: XCTestCase {
    func testAuthFlow_withValidRequestAndResponse_returnsTrue() {
        // Given
        let expectedRequest = URLRequest(url: URL(string: "https://example.com")!)
        let response = Response(url: expectedRequest.url!, statusCode: 200)!
        let authFunction: (URLRequest?, Response?) -> (URLRequest, Bool) = { request, _ in
            (request!, true)
        }
        let functionAuth = FunctionAuth(authFunction: authFunction)

        // When
        let (request, result) = functionAuth.authFlow(request: expectedRequest, lastResponse: response)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(request, expectedRequest)
    }

    func testAuthFlow_withNilRequest_returnsFalse() {
        // Given
        let authFunction: (URLRequest?, Response?) -> (URLRequest, Bool) = { _, _ in
            (URLRequest(url: URL(string: "https://example.com")!), false)
        }
        let functionAuth = FunctionAuth(authFunction: authFunction)

        // When
        let (_, result) = functionAuth.authFlow(request: nil, lastResponse: nil)

        // Then
        XCTAssertFalse(result)

        XCTAssertEqual(functionAuth.needRequestBody, false)
        XCTAssertEqual(functionAuth.needResponseBody, false)
    }
}
