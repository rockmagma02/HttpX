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

final class BaseClientTests: XCTestCase {
    func testInitWithValidCookies() {
        // Define your cookies here. For demonstration, I'm creating a simple cookie.
        let cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .domain: "example.com",
            .path: "/",
            .name: "TestCookie",
            .value: "TestValue",
        ]

        let cookie = HTTPCookie(properties: cookieProperties)!

        let emptyClient = BaseClient(cookies: nil)
        XCTAssertEqual(emptyClient.cookies, [])

        // Initialize the BaseClient with the cookie.
        let client = BaseClient(cookies: CookiesType.cookieArray([cookie]))
        XCTAssertEqual(client.cookies, [cookie])
    }

    func testSetAndGet() {
        let emptyClient = BaseClient()

        emptyClient.setTimeout(10)
        XCTAssertEqual(emptyClient.timeout, 10)

        emptyClient.setEventHooks(EventHooks())
        XCTAssertTrue(emptyClient.eventHooks.request.isEmpty && emptyClient.eventHooks.response.isEmpty)

        emptyClient.setAuth(AuthType.basic(("user", "pass")))
        XCTAssertTrue(emptyClient.auth is BasicAuth)

        emptyClient.setBaseURL(URLType.string("https://example.com"))
        XCTAssertEqual(emptyClient.baseURL, URL(string: "https://example.com"))

        emptyClient.setHeaders(HeadersType.array([("key", "value")]))
        XCTAssertTrue(emptyClient.headers.contains { $0.0 == "key" && $0.1 == "value" })

        emptyClient.setCookies(CookiesType.cookieArray([HTTPCookie(properties: [.name: "cookie", .value: "value", .domain: "example.com", .path: "/"])!]))
        XCTAssertTrue(emptyClient.cookies.contains { $0.name == "cookie" && $0.value == "value" })

        emptyClient.setParams(QueryParamsType.class([URLQueryItem(name: "key", value: "value")]))
        XCTAssertTrue(emptyClient.params.contains { $0.name == "key" && $0.value == "value" })

        emptyClient.setRedirects(follow: false, max: 10)
        XCTAssertFalse(emptyClient.followRedirects)
        XCTAssertEqual(emptyClient.maxRedirects, 10)

        emptyClient.setDefaultEncoding(.utf8)
        XCTAssertEqual(emptyClient.defaultEncoding, .utf8)
    }

    func testInvalidURL() {
        let client = BaseClient()
        XCTAssertThrowsError(try client.buildRequest(method: .get)) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.invalidURL())
        }
    }

    func testInvalidMergeURL() {
        // newURL empty
        XCTAssertThrowsError(try BaseClient.mergeURL(URLType.string(""), original: nil)) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.invalidURL())
        }
    }

    func testMergeHeaders() {
        let originalHeaders = HeadersType.array([("key", "value")]).buildHeaders()
        let newHeaders = HeadersType.array([("key", "value2")])
        XCTAssertTrue(BaseClient.mergeHeaders(newHeaders, original: originalHeaders).contains { $0.0 == "key" && $0.1 == "value2" })
    }

    func testMergeParams() {
        let originalParams = QueryParamsType.array([("key", "value")]).buildQueryItems()
        let newParams = QueryParamsType.array([("key", "value2")])
        XCTAssertTrue(BaseClient.mergeQueryParams(newParams, original: originalParams).contains { $0.name == "key" && $0.value == "value2" })
    }

    func testRefirectMethod() {
        let client = BaseClient()
        var request: URLRequest
        var response: Response

        request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "GET"
        response = Response(url: request.url!, statusCode: 303)!
        XCTAssertEqual(try client.redirectMethod(request: request, response: response), .get)

        request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "DELETE"
        response = Response(url: request.url!, statusCode: 301)!
        XCTAssertEqual(try client.redirectMethod(request: request, response: response), .get)
    }

    func testRedirectURL() throws {
        var request: URLRequest
        var response: Response
        var newURL: URL
        let client = BaseClient()

        // empty location
        request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "GET"
        response = Response(url: request.url!, statusCode: 301, headers: ["Location": ""])!
        XCTAssertThrowsError(try client.redirectURL(request: request, response: response)) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.redirectError())
        }

        // empty host
        request = URLRequest(url: URL(string: "http://example.com")!)
        request.httpMethod = "GET"
        response = Response(url: request.url!, statusCode: 301, headers: ["Location": "https:?query=value"])!
        newURL = try client.redirectURL(request: request, response: response)
        XCTAssertEqual(newURL.absoluteString, "https://example.com?query=value")

        // got fragment
        request = URLRequest(url: URL(string: "http://www.example.com#fragment")!)
        request.httpMethod = "GET"
        response = Response(url: request.url!, statusCode: 301, headers: ["Location": "https://example.com"])!
        newURL = try client.redirectURL(request: request, response: response)
        XCTAssertEqual(newURL.absoluteString, "https://example.com#fragment")

        // no Location
        request = URLRequest(url: URL(string: "http://example.com")!)
        request.httpMethod = "GET"
        response = Response(url: request.url!, statusCode: 301)!
        XCTAssertThrowsError(try client.redirectURL(request: request, response: response)) {
            XCTAssertEqual($0 as? HttpXError, HttpXError.invalidResponse())
        }
    }

    func testRedirectHeader() {
        var request: URLRequest
        var newURL: URL
        let client = BaseClient()

        // change method
        request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("123", forHTTPHeaderField: "Content-Length")
        request.setValue("456", forHTTPHeaderField: "Transfer-Encoding")
        request.setValue("789", forHTTPHeaderField: "test")
        request.httpMethod = "POST"
        newURL = URL(string: "https://example.com")!
        let newHeaders = client.redirectHeaders(request: request, url: newURL, method: .get)
        XCTAssertEqual(newHeaders.count, 1)

        // nil headers
        request = URLRequest(url: URL(string: "https://example.com")!)
        newURL = URL(string: "https://example.com")!
        let newHeaders2 = client.redirectHeaders(request: request, url: newURL, method: .get)
        XCTAssertEqual(newHeaders2.count, 0)
    }

    func testRedirectContent() {
        var request: URLRequest
        let client = BaseClient()

        // change method
        request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "POST"
        request.httpBody = "test".data(using: .utf8)
        let nerData = client.redirectContent(request: request, method: .get)
        XCTAssertNil(nerData)

        // read from stream
        request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "POST"
        request.httpBodyStream = InputStream(data: "test".data(using: .utf8)!)
        let nerData2 = client.redirectContent(request: request, method: .post)
        XCTAssertEqual(nerData2, "test".data(using: .utf8))
    }
}
