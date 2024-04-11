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

final class DigestAuthTests: XCTestCase {
    func testReUseChallenge() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        let _ = try auth.authFlow(request: request, lastResponse: response).0
        let _ = try auth.authFlow(request: request, lastResponse: nil).0

        // We don't test result here, just make sure the code can run without crash, and code coverage can be 100%.
    }

    func testNon401Response() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"test\""]
        )

        let (authedRequest, authStop) = try auth.authFlow(request: request, lastResponse: response)
        XCTAssertNil(authedRequest)
        XCTAssertTrue(authStop)
    }

    func testInvalidWwwAuthenticate() {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)

        (request, _) = try! auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "invalid"]
        )

        let (authedRequest, authStop) = try! auth.authFlow(request: request, lastResponse: response)
        XCTAssertNil(authedRequest)
        XCTAssertTrue(authStop)
    }

    func testInvalidRequest() {
        let auth = DigestAuth(username: "user", password: "pass")

        XCTAssertThrowsError(try auth.authFlow(request: nil, lastResponse: nil)) { error in
            XCTAssertEqual(error as! AuthError, AuthError.invalidRequest())
        }
    }

    func testMoreHashFunction() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5-SESS, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-SESS, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-256, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-256-SESS, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-512, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-512-SESS, stale=FALSE"]
        )
        let _ = try auth.authFlow(request: request, lastResponse: response).0
    }

    func testComplexURL() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        let _ = try auth.authFlow(request: request, lastResponse: response).0
    }

    func testNoQop() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        let _ = try auth.authFlow(request: request, lastResponse: response).0
    }

    func testNonAlgo() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", stale=FALSE"]
        )

        let _ = try auth.authFlow(request: request, lastResponse: response).0
    }

    func testInvalidAlgo() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", stale=FALSE, algorithm=MD55"]
        )

        XCTAssertThrowsError(try auth.authFlow(request: request, lastResponse: response).0) { error in
            XCTAssertEqual(error as? AuthError, AuthError.invalidDigestAuth())
        }
    }

    func testInvalidQop() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth-int\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        XCTAssertThrowsError(try auth.authFlow(request: request, lastResponse: response)) {
            XCTAssertEqual($0 as? AuthError, AuthError.qopNotSupported())
        }

        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"invalid\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        XCTAssertThrowsError(try auth.authFlow(request: request, lastResponse: response)) {
            XCTAssertEqual($0 as? AuthError, AuthError.invalidDigestAuth())
        }
    }

    func testInvalidDigestAuthString() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth-int\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        XCTAssertThrowsError(try auth.authFlow(request: request, lastResponse: response)) {
            XCTAssertEqual($0 as? AuthError, AuthError.invalidDigestAuth())
        }
    }

    func testEscaped() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)

        (request, _) = try auth.authFlow(request: request, lastResponse: nil)
        let response = Response()
        response.URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.\\com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )

        let _ = try auth.authFlow(request: request, lastResponse: response).0
    }

    func testProperty() {
        let auth = DigestAuth(username: "user", password: "pass")
        XCTAssertEqual(auth.needRequestBody, false)
        XCTAssertEqual(auth.needResponseBody, false)
    }
}
