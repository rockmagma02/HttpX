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
    func testAuthFlow_withValidRequestAndResponse_returnsTrue() throws {
        // Given
        let expectedRequest = URLRequest(url: URL(string: "https://example.com")!)
        let authFunction: (URLRequest) -> URLRequest = { request in
            request
        }
        let functionAuth = FunctionAuth(authFunction: authFunction)

        // When
        let authFlow = functionAuth.authFlowAdapter(expectedRequest)
        let request = try authFlow.next()

        // Then
        XCTAssertEqual(request, expectedRequest)
    }

    func testAuthFlow_withValidRequestAndResponse_returnsTrueAsync() async throws {
        // Given
        let expectedRequest = URLRequest(url: URL(string: "https://example.com")!)
        let authFunction: (URLRequest) -> URLRequest = { request in
            request
        }
        let functionAuth = FunctionAuth(authFunction: authFunction)

        // When
        let authFlow = await functionAuth.authFlowAdapter(expectedRequest)
        let request = try await authFlow.next()

        // Then
        XCTAssertEqual(request, expectedRequest)
    }
}
