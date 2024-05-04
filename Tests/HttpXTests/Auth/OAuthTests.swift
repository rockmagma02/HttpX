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

class OAuthTests: XCTestCase {
    func testAuthFlow_withValidRequest_returnsModifiedRequestAndTrue() throws {
        // Given
        let oauth = OAuth(token: "testToken")
        let request = URLRequest(url: URL(string: "https://example.com")!)

        // When
        let authFlow = oauth.authFlowAdapter(request)
        let modifiedRequest = try authFlow.next()

        // Then
        XCTAssertNotNil(modifiedRequest)
        XCTAssertEqual(modifiedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer testToken")
    }

    func testAuthFlow_withValidRequest_returnsModifiedRequestAndTrueAsync() async throws {
        // Given
        let oauth = OAuth(token: "testToken")
        let request = URLRequest(url: URL(string: "https://example.com")!)

        // When
        let authFlow = await oauth.authFlowAdapter(request)
        let modifiedRequest = try await authFlow.next()

        // Then
        XCTAssertNotNil(modifiedRequest)
        XCTAssertEqual(modifiedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer testToken")
    }
}
