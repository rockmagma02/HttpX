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

class ErrorTests: XCTestCase {
    func testAuthErrorEquatable() {
        XCTAssertEqual(AuthError.invalidDigestAuth(), AuthError.invalidDigestAuth())
        XCTAssertEqual(AuthError.invalidRequest(), AuthError.invalidRequest())
        XCTAssertEqual(AuthError.qopNotSupported(), AuthError.qopNotSupported())
        XCTAssertNotEqual(AuthError.invalidDigestAuth(), AuthError.invalidRequest())
    }

    func testHttpXErrorEquatable() {
        XCTAssertEqual(HttpXError.invalidRequest(), HttpXError.invalidRequest())
        XCTAssertEqual(HttpXError.redirectError(), HttpXError.redirectError())
        XCTAssertEqual(HttpXError.invalidURL(), HttpXError.invalidURL())
        XCTAssertEqual(HttpXError.invalidResponse(), HttpXError.invalidResponse())
        XCTAssertEqual(HttpXError.networkError(code: 404), HttpXError.networkError(code: 404))
        XCTAssertNotEqual(HttpXError.networkError(code: 404), HttpXError.networkError(code: 500))
        XCTAssertNotEqual(HttpXError.invalidRequest(), HttpXError.invalidURL())
    }

    func testBuildErrorWithURLError() {
        // Given a URLError
        let error = URLError(.timedOut)

        // When building an HttpXError from it
        let result = buildError(error)

        XCTAssertEqual(result as? HttpXError, HttpXError.networkError(message: "", code: error.errorCode))
    }

    func testBuildErrorWithNonURLError() {
        // Given a generic error
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)

        // When building an error from it
        let result = buildError(error)

        // Then the result should be the same as the input error
        XCTAssertTrue(result as NSError === error)
    }
}
