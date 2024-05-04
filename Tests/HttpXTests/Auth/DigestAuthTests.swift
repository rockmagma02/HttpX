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

final class DigestAuthTests: XCTestCase {
    func testReUseChallenge() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        var authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()

        // We don't test result here, just make sure the code can run without crash, and code coverage can be 100%.
    }

    func testReUseChallengeAsync() async throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        var authFlow = await auth.authFlowAdapter(request!)
        request = try await authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        _ = try await authFlow.send(response)

        authFlow = await auth.authFlowAdapter(request!)
        request = try await authFlow.next()

        // We don't test result here, just make sure the code can run without crash, and code coverage can be 100%.
    }

    func testNon401Response() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"test\""]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        do {
            _ = try authFlow.send(response)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is StopIteration<NoneType>)
        }
    }

    func testNon401ResponseAsync() async throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        let authFlow = await auth.authFlowAdapter(request!)
        request = try await authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"test\""]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        do {
            _ = try await authFlow.send(response)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is StopIteration<NoneType>)
        }
    }

    func testInvalidWwwAuthenticate() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)

        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "invalid"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        do {
            _ = try authFlow.send(response)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is StopIteration<NoneType>)
        }
    }

    func testInvalidWwwAuthenticateAsync() async throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)

        let authFlow = await auth.authFlowAdapter(request!)
        request = try await authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "invalid"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        do {
            _ = try await authFlow.send(response)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is StopIteration<NoneType>)
        }
    }

    func testMoreHashFunction() throws {
        var auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com")!)
        var authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        var URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5-SESS, stale=FALSE"]
        )
        var response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-SESS, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-256, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-256-SESS, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-512, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)

        auth = DigestAuth(username: "user", password: "pass")
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=SHA-512-SESS, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!
        _ = try authFlow.send(response)
    }

    func testComplexURL() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        let _ = try authFlow.send(response)
    }

    func testNoQop() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        let _ = try authFlow.send(response)
    }

    func testNonAlgo() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!
        let _ = try authFlow.send(response)
    }

    func testInvalidAlgo() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", stale=FALSE, algorithm=MD55"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!

        XCTAssertThrowsError(try authFlow.send(response)) { error in
            let error = (error as! Terminated).error
            XCTAssertEqual((error as? URLError)?.code, URLError(.userCancelledAuthentication).code)
        }
    }

    func testInvalidQop() throws {
        var auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        var authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        var URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth-int\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        var response = Response(HTTPURLResponse: URLResponse!)!

        XCTAssertThrowsError(try authFlow.send(response)) { error in
            let error = (error as! Terminated).error
            XCTAssertEqual((error as? URLError)?.code, URLError(.userCancelledAuthentication).code)
        }

        auth = DigestAuth(username: "user", password: "pass")
        request = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"invalid\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        response = Response(HTTPURLResponse: URLResponse!)!

        XCTAssertThrowsError(try authFlow.send(response)) { error in
            let error = (error as! Terminated).error
            XCTAssertEqual((error as? URLError)?.code, URLError(.userCancelledAuthentication).code)
        }
    }

    func testInvalidDigestAuthString() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", qop=\"auth-int\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!

        XCTAssertThrowsError(try authFlow.send(response)) { error in
            let error = (error as! Terminated).error
            XCTAssertEqual((error as? URLError)?.code, URLError(.userCancelledAuthentication).code)
        }
    }

    func testEscaped() throws {
        let auth = DigestAuth(username: "user", password: "pass")
        var request: URLRequest? = URLRequest(url: URL(string: "http://example.com/with/path?query=with")!)
        let authFlow = auth.authFlowAdapter(request!)
        request = try authFlow.next()
        let URLResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 401, httpVersion: nil,
            headerFields: ["Www-Authenticate": "digest realm=\"me@kennethreitz.\\com\", nonce=\"f84b8428b38019eefd5dbdb8e72bf7d6\", opaque=\"ee1a7a03d8c7032f17dd33b3043db4c6\", algorithm=MD5, stale=FALSE"]
        )
        let response = Response(HTTPURLResponse: URLResponse!)!

        _ = try authFlow.send(response)
    }

    func testProperty() {
        let auth = DigestAuth(username: "user", password: "pass")
        XCTAssertEqual(auth.needRequestBody, false)
        XCTAssertEqual(auth.needResponseBody, false)
    }
}
